import smtplib
import json
import re
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import FastAPI, Request, HTTPException, File, UploadFile, Depends, Form
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
import logging
import os
from datetime import datetime
from typing import Dict, Any, Optional
from pydantic import BaseModel

# Initialize FastAPI
app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MongoDB Connection
try:
    client = MongoClient('mongodb://localhost:27017')
    db = client['studentERP']
    admins_collection = db['admins']
    admissions_collection = db['admissions']
    students_collection = db['students']
    payments_collection = db['payments']
    queries_collection = db['document_queries']
    faculty_collection = db['faculty_db']
    documents_collection = db['documents']
    logger.info("✅ MongoDB connected successfully!")
except Exception as e:
    logger.error(f"❌ MongoDB connection failed: {e}")

# File upload configuration
UPLOAD_FOLDER = 'Uploads'
ALLOWED_EXTENSIONS = {'pdf', 'jpg', 'jpeg', 'png'}
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# SMTP Configuration
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_EMAIL = "balsarafrohan627@gmail.com"  # Replace with your email
SMTP_PASSWORD = "zobi sxvl pjfv cneu"  # Replace with your app-specific password

# Pydantic Models
class AdminSignup(BaseModel):
    employee_id: str
    password: str
    confirm_password: str

class AdminLogin(BaseModel):
    employee_id: str
    password: str

class StudentAdmit(BaseModel):
    email: str
    phone: str
    category: str
    allotment_number: str
    department: str
    division: str

class StudentForm(BaseModel):
    student_id: str
    address: str
    guardian_name: str
    dob: str

class PayFees(BaseModel):
    student_id: str
    amount_paid: float

class FeeReminder(BaseModel):
    student_id: str

class ScholarshipNotify(BaseModel):
    student_id: str

class ResultReminder(BaseModel):
    student_id: str

class PromoteStudent(BaseModel):
    student_id: str
    new_year: str

class UpdateStudent(BaseModel):
    updated_data: Dict[str, Any]
    admin: str

class DocumentQuery(BaseModel):
    student_id: str
    query_type: str
    comment: Optional[str] = ""

class VerifyDocument(BaseModel):
    student_id: str
    document_url: str
    verified: bool

class FacultyData(BaseModel):
    name: str
    employee_id: str
    department: str
    experience: str
    email: str
    phone: str
    salary: float
    password: str

class StudentLogin(BaseModel):
    student_id: str
    password: str
    email: str

class AdmissionForm(BaseModel):
    studentId: str
    name: str
    dob: str
    address: str
    fatherName: str
    motherName: str
    marks10: int
    marks12: int

# Helper Functions
def allowed_file(filename: str) -> bool:
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def send_email(to_email: str, subject: str, message: str, name: str = "Student") -> bool:
    try:
        msg = MIMEMultipart()
        msg['From'] = SMTP_EMAIL
        msg['To'] = to_email
        msg['Subject'] = subject
        body = f"Hello {name},\n\n{message}\n\nThank you."
        msg.attach(MIMEText(body, 'plain', 'utf-8'))
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_EMAIL, SMTP_PASSWORD)
            server.sendmail(SMTP_EMAIL, to_email, msg.as_string())
        logger.info(f"📧 Email sent to {to_email}")
        return True
    except Exception as e:
        logger.error(f"❌ Failed to send email: {e}")
        return False

def hash_password(password: str) -> str:
    return generate_password_hash(password, method='pbkdf2:sha256')

def verify_password(stored_password: str, provided_password: str) -> bool:
    return check_password_hash(stored_password, provided_password)

def generate_student_id(department: str, division: str) -> tuple[str, int]:
    clg_code = "4088"
    today = datetime.now().strftime("%d%m%Y")
    last_student = students_collection.find_one(
        {"department": department, "division": division},
        sort=[("roll_no", -1)]
    )
    next_roll = (last_student["roll_no"] + 1) if last_student else 1
    roll_str = f"{next_roll:02d}"
    student_id = f"{clg_code}{department.upper()}{today}{roll_str}"
    return student_id, next_roll

# Admin Routes
@app.post("/admin_signup")
async def admin_signup(data: AdminSignup):
    if data.password != data.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")

    existing_admin = admins_collection.find_one({"employee_id": data.employee_id})
    if existing_admin:
        raise HTTPException(status_code=400, detail="Admin already exists")

    hashed_password = hash_password(data.password)
    new_admin = {"employee_id": data.employee_id, "password": hashed_password}
    admins_collection.insert_one(new_admin)

    logger.info(f"✅ Admin Signed Up: {data.employee_id}")
    return {"status": "success", "message": "Admin signup successful"}

@app.post("/admin_login")
async def admin_login(data: AdminLogin):
    existing_admin = admins_collection.find_one({"employee_id": data.employee_id})
    if not existing_admin:
        raise HTTPException(status_code=400, detail="Admin not found")

    if not verify_password(existing_admin['password'], data.password):
        raise HTTPException(status_code=400, detail="Invalid password")

    logger.info(f"✅ Admin Logged In: {data.employee_id}")
    return {"status": "success", "message": "Admin login successful"}

# Student Routes
@app.post("/admit_student")
async def admit_student(data: StudentAdmit):
    if not data.email or not re.match(r"[^@]+@[^@]+\.[^@]+", data.email):
        raise HTTPException(status_code=400, detail="Valid email address is required")

    student_id, roll_no = generate_student_id(data.department, data.division)
    scholarship_eligible = data.category.lower() != "open"
    form_link = f"http://localhost:5500?student_id={student_id}"

    new_student = {
        "student_id": student_id,
        "email": data.email,
        "phone": data.phone,
        "category": data.category,
        "scholarship_eligible": scholarship_eligible,
        "allotment_number": data.allotment_number,
        "year": "FE",
        "department": data.department,
        "division": data.division,
        "form_link": form_link,
        "form_completed": False,
        "roll_no": roll_no,
        "created_at": datetime.utcnow()
    }
    students_collection.insert_one(new_student)

    email_sent = send_email(data.email, "Complete Your Admission Form", f"Please complete your admission form: {form_link}")
    logger.info(f"✅ Student Admitted: ID={student_id}, Roll={roll_no}")
    return {
        "status": "success",
        "student_id": student_id,
        "form_link": form_link,
        "email_sent": email_sent
    }

@app.post("/student_submit_form")
async def submit_student_form(data: StudentForm):
    existing_student = students_collection.find_one({"student_id": data.student_id})
    if not existing_student:
        raise HTTPException(status_code=404, detail="Student not found")

    students_collection.update_one(
        {"student_id": data.student_id},
        {"$set": {
            "address": data.address,
            "guardian_name": data.guardian_name,
            "dob": data.dob,
            "form_completed": True
        }}
    )
    logger.info(f"✅ Student Form Submitted: {data.student_id}")
    return {"status": "success", "message": "Student form submitted successfully"}

@app.get("/get_student_data/{student_id}")
async def get_student_data(student_id: str):
    student = students_collection.find_one({"student_id": student_id}, {"_id": 0})
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    return {"status": "success", "student": student}

@app.post("/pay_fees")
async def pay_fees(data: PayFees):
    if not isinstance(data.amount_paid, (int, float)) or data.amount_paid <= 0:
        raise HTTPException(status_code=400, detail="Payment amount must be a positive number")
    if not data.student_id:
        raise HTTPException(status_code=400, detail="Student ID is required")

    student = students_collection.find_one({"student_id": data.student_id})
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    category = student.get("category", "non-open").lower()
    total_fees = 96000 if category == "open" else 53000
    scholarship_eligible = student.get("scholarship_eligible", False)
    scholarship_amount = 43000 if scholarship_eligible else 0
    payable_fees = total_fees - scholarship_amount

    existing_payment = payments_collection.find_one({"student_id": data.student_id})
    already_paid = existing_payment["amount_paid"] if existing_payment else 0
    new_total_paid = already_paid + data.amount_paid
    remaining_fees = max(0, payable_fees - new_total_paid)

    if new_total_paid > payable_fees:
        logger.warning(f"Overpayment detected: student_id={data.student_id}, excess_amount=₹{new_total_paid - payable_fees}")

    if existing_payment:
        payments_collection.update_one(
            {"student_id": data.student_id},
            {"$set": {
                "amount_paid": new_total_paid,
                "remaining_fees": remaining_fees,
                "excess_amount": max(0, new_total_paid - payable_fees),
                "last_payment_date": datetime.utcnow()
            }}
        )
    else:
        payments_collection.insert_one({
            "student_id": data.student_id,
            "amount_paid": new_total_paid,
            "remaining_fees": remaining_fees,
            "excess_amount": max(0, new_total_paid - payable_fees),
            "last_payment_date": datetime.utcnow()
        })

    logger.info(f"✅ Fees Paid: {data.student_id} | Paid: ₹{data.amount_paid} | Total Paid: ₹{new_total_paid} | Remaining: ₹{remaining_fees}")
    return {
        "status": "success",
        "message": f"Payment of ₹{data.amount_paid} received.",
        "total_paid": new_total_paid,
        "remaining_fees": remaining_fees,
        "excess_amount": max(0, new_total_paid - payable_fees)
    }

@app.get("/payment_details/{student_id}")
async def get_payment_details(student_id: str):
    payment = payments_collection.find_one({"student_id": student_id}, {"_id": 0})
    if not payment:
        raise HTTPException(status_code=404, detail="No payment record found for this student.")
    return {"status": "success", "payment": payment}

@app.get("/get_all_fees")
async def get_all_fees():
    students = list(students_collection.find({}, {"_id": 0, "student_id": 1, "scholarship_eligible": 1}))
    fees_data = []
    for student in students:
        total_fees = 96000
        scholarship_amount = 43000 if student["scholarship_eligible"] else 0
        payable_fees = total_fees - scholarship_amount
        payment = payments_collection.find_one({"student_id": student["student_id"]}, {"_id": 0})
        amount_paid = payment["amount_paid"] if payment else 0
        remaining_fees = payable_fees - amount_paid
        fees_data.append({
            "student_id": student["student_id"],
            "total_fees": payable_fees,
            "amount_paid": amount_paid,
            "remaining_fees": remaining_fees
        })
    return {"status": "success", "students": fees_data}

@app.post("/send_fee_reminder")
async def send_fee_reminder(data: FeeReminder):
    student = students_collection.find_one({"student_id": data.student_id}, {"_id": 0, "email": 1, "name": 1})
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    email_sent = send_email(student["email"], "Reminder: Pending Fees Payment", "Please pay your pending fees.", student["name"])
    if email_sent:
        return {"status": "success", "message": f"Fee reminder sent to {student['email']}"}
    raise HTTPException(status_code=500, detail="Failed to send email")

@app.get("/get_scholarship_students")
async def get_scholarship_students():
    students = list(students_collection.find(
        {"category": {"$ne": "OPEN"}},
        {"_id": 0, "student_id": 1, "name": 1, "department": 1, "email": 1, "form_completed": 1, "year": 1}
    ))
    for student in students:
        payment = payments_collection.find_one({"student_id": student["student_id"]}, {"_id": 0})
        admission = admissions_collection.find_one({"studentId": student["student_id"]}, {"_id": 0, "name": 1})
        student["name"] = admission["name"] if admission and admission.get("name") else "Unknown"
        student["total_fees"] = 96000 - (43000 if student.get("scholarship_eligible", False) else 0)
        student["amount_paid"] = payment["amount_paid"] if payment else 0
        student["remaining_fees"] = student["total_fees"] - student["amount_paid"]
    return {"status": "success", "students": students}

@app.post("/notify_scholarship_student")
async def notify_scholarship_student(data: ScholarshipNotify):
    student = students_collection.find_one({"student_id": data.student_id})
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    if student.get("form_completed", False):
        return {"status": "info", "message": "Scholarship form already submitted"}

    email_sent = send_email(
        student["email"],
        "Reminder: Scholarship Form Submission",
        "Please submit your scholarship form as soon as possible.",
        student.get("name", "Student")
    )
    if email_sent:
        return {"status": "success", "message": f"Scholarship reminder sent to {student['email']}"}
    raise HTTPException(status_code=500, detail="Failed to send email")

@app.get("/get_student_promotion")
async def get_student_promotion():
    students = list(students_collection.find({}, {"_id": 0, "student_id": 1, "name": 1, "email": 1, "year": 1, "result_updated": 1, "department": 1}))
    return {"status": "success", "students": students}

@app.post("/send_result_reminder")
async def send_result_reminder(data: ResultReminder):
    student = students_collection.find_one(
        {"student_id": data.student_id},
        {"_id": 0, "email": 1, "name": 1, "result_updated": 1}
    )
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    if student.get("result_updated", False):
        return {"status": "info", "message": "Result already updated"}

    email_sent = send_email(
        student["email"],
        "Result Update Reminder",
        f"Please update your result to be eligible for promotion.",
        student.get("name", "Student")
    )
    if email_sent:
        return {"status": "success", "message": f"Result reminder sent to {student['email']}"}
    raise HTTPException(status_code=500, detail="Failed to send email")

@app.post("/promote_student")
async def promote_student(data: PromoteStudent):
    student = students_collection.find_one({"student_id": data.student_id})
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    if not student.get("result_updated", False):
        raise HTTPException(status_code=400, detail="Student result not updated, promotion not allowed")

    students_collection.update_one(
        {"student_id": data.student_id},
        {"$set": {"year": data.new_year}}
    )
    logger.info(f"✅ Student {student.get('name', 'Unknown')} promoted to {data.new_year}")
    return {"status": "success", "message": f"Student {student.get('name', 'Unknown')} promoted to {data.new_year}"}

@app.post("/update_student")
async def update_student(data: UpdateStudent):
    student_id = data.updated_data.get("student_id")
    if not student_id or not data.updated_data:
        raise HTTPException(status_code=400, detail="Missing student_id or updated_data")

    student = students_collection.find_one({"student_id": student_id})
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    changes = {}
    for key, new_value in data.updated_data.items():
        old_value = student.get(key)
        if old_value != new_value and not (old_value is None and new_value is None):
            changes[key] = {"old": old_value, "new": new_value}

    if changes:
        students_collection.update_one(
            {"student_id": student_id},
            {"$set": data.updated_data}
        )
        email_sent = send_email(
            student["email"],
            "Student Profile Updated",
            f"Your profile has been updated:\n{json.dumps(changes, indent=2)}\nContact admin: {data.admin}",
            student.get("name", "Student")
        )
        return {
            "status": "success",
            "message": "Student details updated",
            "changes": changes,
            "email_sent": email_sent
        }
    return {"status": "info", "message": "No changes detected"}

# Document Routes
@app.post("/upload_document")
async def upload_document(student_id: str = Form(...), file: UploadFile = File(...)):
    if not student_id:
        raise HTTPException(status_code=400, detail="Missing student_id")
    if not file.filename:
        raise HTTPException(status_code=400, detail="No selected file")
    if not allowed_file(file.filename):
        raise HTTPException(status_code=400, detail="Invalid file type")

    filename = secure_filename(file.filename)
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    with open(file_path, "wb") as f:
        f.write(await file.read())

    document = {
        "student_id": student_id,
        "file_name": filename,
        "url": f"http://localhost:5000/files/{filename}",
        "verified": False,
        "uploaded_at": datetime.utcnow().isoformat()
    }
    document_id = documents_collection.insert_one(document).inserted_id

    students_collection.update_one(
        {"student_id": student_id},
        {"$push": {
            "documents": {
                "url": document["url"],
                "file_name": filename,
                "verified": False
            }
        }}
    )

    return {"message": "Document uploaded", "document_id": str(document_id)}

@app.get("/get_students")
async def get_students():
    students = list(students_collection.find({}, {"_id": 0}))
    return {"students": students}

@app.patch("/verify_document")
async def verify_document(data: VerifyDocument):
    if not all([data.student_id, data.document_url, data.verified is not None]):
        raise HTTPException(status_code=400, detail="Missing required fields")

    result = students_collection.update_one(
        {"student_id": data.student_id, "documents.url": data.document_url},
        {"$set": {"documents.$.verified": data.verified}}
    )

    if result.modified_count > 0:
        documents_collection.update_one(
            {"student_id": data.student_id, "url": data.document_url},
            {"$set": {"verified": data.verified}}
        )
        return {"message": "Document verification updated"}
    raise HTTPException(status_code=404, detail="Document not found")

@app.post("/send_document_query")
async def send_document_query(data: DocumentQuery):
    if not all([data.student_id, data.query_type]):
        raise HTTPException(status_code=400, detail="Missing required fields")

    query_data = {
        "student_id": data.student_id,
        "query_type": data.query_type,
        "comment": data.comment,
        "status": "Pending",
        "created_at": datetime.utcnow()
    }
    queries_collection.insert_one(query_data)

    student = students_collection.find_one({"student_id": data.student_id})
    if student:
        send_email(
            student["email"],
            "Document Query",
            f"A query has been raised regarding your document:\nType: {data.query_type}\nComment: {data.comment}",
            student.get("name", "Student")
        )

    return {"message": "Query sent"}

@app.get("/serve_files/{filename}")
async def serve_file(filename: str):
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(file_path)

# Faculty Routes
@app.post("/add_faculty")
async def add_faculty(data: FacultyData):
    faculty_data = {
        "name": data.name,
        "employee_id": data.employee_id,
        "department": data.department,
        "experience": data.experience,
        "email": data.email,
        "phone": data.phone,
        "salary": data.salary,
        "password": data.password
    }
    faculty_collection.insert_one(faculty_data)

    email_sent = send_email(
        faculty_data["email"],
        "Faculty Login Credentials",
        f"Employee ID: {faculty_data['employee_id']}\nPassword: {faculty_data['password']}",
        faculty_data["name"]
    )
    if email_sent:
        return {"status": "success", "message": "Faculty added and email sent"}
    raise HTTPException(status_code=500, detail="Faculty added, but email failed")

@app.get("/get_faculty")
async def get_faculty():
    faculty_list = list(faculty_collection.find({}, {"_id": 0}))
    return {"faculty": faculty_list}

# Student Login
@app.post("/student_login")
async def student_login(data: StudentLogin):
    student1 = admissions_collection.find_one({"studentId": data.student_id})
    student = students_collection.find_one({"email": data.email})
    if not student1:
        raise HTTPException(status_code=401, detail="Incorrect ID")
    if data.password != data.student_id:  # Simplified password check
        raise HTTPException(status_code=401, detail="Password must match Student ID")

    def to_string(value):
        if isinstance(value, list) and len(value) > 0:
            return str(value[0])
        return value if value is not None else "N/A"

    return {
        "student": {
            "student_id": to_string(student1.get("studentId")),
            "name": to_string(student1.get("name", "Unknown")),
            "address": to_string(student1.get("address")),
            "fathers_name": to_string(student1.get("fatherName")),
            "mothers_name": to_string(student1.get("motherName")),
            "marks_10": to_string(student1.get("marks10")),
            "marks_12": to_string(student1.get("marks12")),
            "email": to_string(student.get("email")),
            "department": to_string(student.get("department")),
        }
    }

# Admission Form Routes
@app.get("/validate_student_id/{student_id}")
async def validate_student_id(student_id: str):
    student_exists = students_collection.find_one({"student_id": student_id})
    if not student_exists:
        return {"status": "error", "message": "❌ Invalid Student ID. Contact Main Control Center."}

    admission = admissions_collection.find_one({"studentId": student_id}, {"_id": 0})
    if not admission:
        return {"status": "pending", "message": "⚠️ Student ID is valid, but admission form is not submitted yet."}

    # Normalize keys for Flutter
    normalized_admission = {
        "studentId": admission.get("studentId"),
        "name": admission.get("name", "Unknown"),
        "address": admission.get("address", "N/A"),
        "fathers name": admission.get("fatherName", "N/A"),
        "mothers name": admission.get("motherName", "N/A"),
        "10th marks": admission.get("marks10", "N/A"),
        "12th marks": admission.get("marks12", "N/A"),
        "dob": admission.get("dob", "N/A")
    }
    return {"status": "success", "student_data": normalized_admission}

@app.post("/update_admission_form")
async def update_admission_form(data: AdmissionForm):
    if not data.studentId:
        raise HTTPException(status_code=400, detail="Student ID is missing")

    result = admissions_collection.update_one(
        {"studentId": data.studentId},
        {"$set": {
            "name": data.name,
            "dob": data.dob,
            "address": data.address,
            "fatherName": data.fatherName,
            "motherName": data.motherName,
            "marks10": data.marks10,
            "marks12": data.marks12,
        }},
        upsert=True
    )
    if result.modified_count == 1:
        return {"status": "success", "message": "Admission form updated"}
    raise HTTPException(status_code=400, detail="No changes made or form not found")

# Test Route
@app.get("/test")
async def test_route():
    return {"status": "success", "message": "API is working!"}

