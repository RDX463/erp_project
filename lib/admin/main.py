import smtplib
import json
from typing import List
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi.responses import JSONResponse
from bson import ObjectId
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware
import logging
import random
import string
from fastapi import APIRouter
from datetime import datetime
from fastapi import Body
from fastapi import Request, HTTPException, Body
from motor.motor_asyncio import AsyncIOMotorClient

# Initialize FastAPI
app = FastAPI()

admin_router = APIRouter()
student_router = APIRouter()

app.include_router(admin_router, prefix="/admin")
app.include_router(student_router, prefix="/student")

# Enable CORS for frontend communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure Logging
logging.basicConfig(level=logging.INFO)

# MongoDB Connection
try:
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    db = client.studentERP
    admins_collection = db.admins
    students_collection = db.students
    payments_collection = db.payments
    queries_collection = db.document_queries
    faculty_collection = db.faculty_db
    faculty_leaves_collection = db.faculty_leaves
    logging.info("✅ MongoDB connected successfully!")
except Exception as e:
    logging.error(f"❌ MongoDB connection failed: {e}")

# Password Hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 🔹 Student Fees Model
class StudentFeesPayment(BaseModel):
    student_id: str
    amount_paid: int

# SMTP Configuration
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_EMAIL = "balsarafrohan627@gmail.com"  # Replace with your email
SMTP_PASSWORD = "zobi sxvl pjfv cneu"  # Replace with your email password

# 🔹 Admin Models
class AdminSignup(BaseModel):
    employee_id: str
    password: str
    confirm_password: str

class AdminLogin(BaseModel):
    employee_id: str
    password: str

# 🔹 Student Models
class StudentAdmission(BaseModel):
    name: str
    email: EmailStr
    phone: str
    category: str  # OBC, SC, NT, ST, OPEN
    allotment_number: str
    department: str  # COM, AIDS, MECH, ENTC, CIVIL

class StudentFormSubmission(BaseModel):
    student_id: str
    address: str
    guardian_name: str
    dob: str  # Format: YYYY-MM-DD
    
# 🔹 Student Scholarship Model
class ScholarshipNotification(BaseModel):
    student_id: str
    
# Pydantic Model for Document Query
class DocumentQuery(BaseModel):
    student_id: str
    query_type: str
    comment: str

# Define Leave Request Model
class LeaveUpdate(BaseModel):
    employee_id: str
    status: str

# ✅ ADMIN: Signup API
@app.post("/admin_signup")
async def admin_signup(admin: AdminSignup):
    if admin.password != admin.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")
    
    existing_admin = await admins_collection.find_one({"employee_id": admin.employee_id})
    if existing_admin:
        raise HTTPException(status_code=400, detail="Admin already exists")
    
    hashed_password = pwd_context.hash(admin.password)
    new_admin = {"employee_id": admin.employee_id, "password": hashed_password}
    await admins_collection.insert_one(new_admin)
    
    logging.info(f"✅ Admin Signed Up: {admin.employee_id}")
    return {"status": "success", "message": "Admin signup successful"}

# ✅ ADMIN: Login API
@app.post("/admin_login")
async def admin_login(admin: AdminLogin):
    existing_admin = await admins_collection.find_one({"employee_id": admin.employee_id})

    if not existing_admin:
        raise HTTPException(status_code=400, detail="Admin not found")

    stored_password = existing_admin.get("password")  
    if not stored_password or not pwd_context.verify(admin.password, stored_password):
        raise HTTPException(status_code=400, detail="Invalid password")

    logging.info(f"✅ Admin Logged In: {admin.employee_id}")
    return {"status": "success", "message": "Admin login successful"}

# 🔹 Generate a unique Student ID
def generate_student_id():
    return "STU" + ''.join(random.choices(string.digits, k=6))

# 🔹 Generate a unique form link
def generate_form_link(student_id):
    return "http://127.0.0.1:5500"

# 🔹 Send email to student
def send_email(email: str, name: str, form_link: str):
    try:
        msg = MIMEText(f"Hello {name},\n\nPlease complete your admission form by clicking the link below:\n{form_link}\n\nThank you.")
        msg["Subject"] = "Complete Your Admission Form"
        msg["From"] = SMTP_EMAIL
        msg["To"] = email

        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SMTP_EMAIL, SMTP_PASSWORD)
        server.sendmail(SMTP_EMAIL, email, msg.as_string())
        server.quit()
        
        logging.info(f"📧 Email sent to {email}")
        return True
    except Exception as e:
        logging.error(f"❌ Email sending failed: {e}")
        return False

# ✅ STUDENT: Admission API
@app.post("/admit_student")
async def admit_student(student: StudentAdmission):
    student_id = generate_student_id()
    scholarship_eligible = student.category.lower() != "open"
    form_link = generate_form_link(student_id)

    new_student = {
        "student_id": student_id,
        "name": student.name,
        "email": student.email,
        "phone": student.phone,
        "category": student.category,
        "scholarship_eligible": scholarship_eligible,
        "allotment_number": student.allotment_number,
        "year": "FE",
        "department": student.department,
        "form_link": form_link,
        "form_completed": False,
        "created_at": datetime.utcnow()
    }

    await students_collection.insert_one(new_student)

    # Send email with form link
    email_sent = send_email(student.email, student.name, form_link)
    
    if not email_sent:
        return {"status": "error", "message": "Student admitted, but email failed to send"}

    logging.info(f"✅ Student Admitted: {student.name} (ID: {student_id})")
    return {"status": "success", "message": "Student admitted successfully", "student_id": student_id, "form_link": form_link}

# ✅ STUDENT: Form Submission API
@app.post("/submit_student_form")
async def submit_student_form(student_form: StudentFormSubmission):
    existing_student = await students_collection.find_one({"student_id": student_form.student_id})

    if not existing_student:
        raise HTTPException(status_code=404, detail="Student not found")

    await students_collection.update_one(
        {"student_id": student_form.student_id},
        {"$set": {
            "address": student_form.address,
            "guardian_name": student_form.guardian_name,
            "dob": student_form.dob,
            "form_completed": True
        }}
    )

    logging.info(f"✅ Student Form Submitted: {student_form.student_id}")
    return {"status": "success", "message": "Student form submitted successfully"}

# ✅ STUDENT: Fetch Details API
@app.get("/get_student_data/{student_id}")
async def get_student_data(student_id: str):
    student = await students_collection.find_one({"student_id": student_id}, {"_id": 0})
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    return {"status": "success", "student": student}

@app.post("/pay_fees")
async def pay_fees(fees_data: StudentFeesPayment):
    student = await students_collection.find_one({"student_id": fees_data.student_id})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    total_fees = 96000
    scholarship_amount = 43000 if student.get("scholarship_eligible", False) else 0
    payable_fees = total_fees - scholarship_amount

    # Fetch existing payment details
    existing_payment = await payments_collection.find_one({"student_id": fees_data.student_id})

    # Calculate amounts
    already_paid = existing_payment["amount_paid"] if existing_payment else 0
    new_total_paid = already_paid + fees_data.amount_paid
    remaining_fees = max(0, payable_fees - new_total_paid)

    # Ensure payment does not exceed payable fees
    if new_total_paid > payable_fees:
        raise HTTPException(status_code=400, detail=f"Payment exceeds total fees. Remaining balance: ₹{payable_fees - already_paid}")

    # Update or insert payment record
    if existing_payment:
        await payments_collection.update_one(
            {"student_id": fees_data.student_id},
            {"$set": {
                "amount_paid": new_total_paid,
                "remaining_fees": remaining_fees,
                "last_payment_date": datetime.utcnow()
            }}
        )
    else:
        await payments_collection.insert_one({
            "student_id": fees_data.student_id,
            "amount_paid": fees_data.amount_paid,
            "remaining_fees": remaining_fees,
            "last_payment_date": datetime.utcnow()
        })

    logging.info(f"✅ Fees Paid: {fees_data.student_id} | Paid: ₹{fees_data.amount_paid} | Remaining: ₹{remaining_fees}")

    return {
        "status": "success",
        "message": f"Payment of ₹{fees_data.amount_paid} received.",
        "total_paid": new_total_paid,
        "remaining_fees": remaining_fees
    }

# ✅ STUDENT: Fetch Payment Details API
@app.get("/get_payment_details/{student_id}")
async def get_payment_details(student_id: str):
    payment = await payments_collection.find_one({"student_id": student_id}, {"_id": 0})

    if not payment:
        raise HTTPException(status_code=404, detail="No payment record found for this student.")

    return {
        "status": "success",
        "payment_details": payment
    }

@app.get("/get_all_fees")
async def get_all_fees():
    students = await students_collection.find({}, {"_id": 0, "student_id": 1, "name": 1, "scholarship_eligible": 1}).to_list(length=None)

    fees_data = []
    for student in students:
        total_fees = 96000
        scholarship_amount = 43000 if student["scholarship_eligible"] else 0
        payable_fees = total_fees - scholarship_amount

        payment = await payments_collection.find_one({"student_id": student["student_id"]}, {"_id": 0})
        amount_paid = payment["amount_paid"] if payment else 0
        remaining_fees = payable_fees - amount_paid

        fees_data.append({
            "student_id": student["student_id"],
            "name": student["name"],
            "total_fees": payable_fees,
            "amount_paid": amount_paid,
            "remaining_fees": remaining_fees
        })

    return {"status": "success", "students": fees_data}

@app.post("/send_fee_reminder")
async def send_fee_reminder(data: dict):
    student_id = data.get("student_id")
    student = await students_collection.find_one({"student_id": student_id}, {"_id": 0, "email": 1, "name": 1})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    email_sent = send_email(student["email"], student["name"], "Reminder: Pending Fees Payment")

    if email_sent:
        logging.info(f"📧 Reminder Email sent to {student['email']}")
        return {"status": "success", "message": f"Fee reminder sent to {student['email']}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send email")
    
# ✅ Fetch Students Eligible for Scholarships
@app.get("/get_scholarship_students")
async def get_scholarship_students():
    try:
        students = await students_collection.find(
            {"category": {"$ne": "OPEN"}},
            {"_id": 0, "student_id": 1, "name": 1, "department": 1, "email": 1, "form_completed": 1,"year":1}
        ).to_list(length=None)

        # Fetch payment details for each student
        for student in students:
            payment = await payments_collection.find_one({"student_id": student["student_id"]}, {"_id": 0})
            student["total_fees"] = 96000 - (43000 if student.get("scholarship_eligible", False) else 0)
            student["amount_paid"] = payment["amount_paid"] if payment else 0
            student["remaining_fees"] = student["total_fees"] - student["amount_paid"]

        return JSONResponse(content={"status": "success", "students": students}, status_code=200)
    
    except Exception as e:
        logging.error(f"❌ Error fetching scholarship students: {e}")
        return JSONResponse(content={"status": "error", "message": str(e)}, status_code=500)

# 🔹 Send Scholarship Form Notification Email
def send_scholarship_email(email: str, name: str):
    try:
        msg = MIMEText(f"Hello {name},\n\nPlease submit your scholarship form as soon as possible.\n\nThank you.")
        msg["Subject"] = "Reminder: Scholarship Form Submission"
        msg["From"] = SMTP_EMAIL
        msg["To"] = email

        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SMTP_EMAIL, SMTP_PASSWORD)
        server.sendmail(SMTP_EMAIL, email, msg.as_string())
        server.quit()

        logging.info(f"📧 Scholarship form reminder sent to {email}")
        return True
    except Exception as e:
        logging.error(f"❌ Scholarship email sending failed: {e}")
        return False

# ✅ Notify Students for Scholarship Form Submission
@app.post("/notify_scholarship_student")
async def notify_scholarship_student(data: ScholarshipNotification):
    student = await students_collection.find_one({"student_id": data.student_id})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    if student.get("form_completed", False):
        return {"status": "info", "message": "Scholarship form already submitted"}

    email_sent = send_scholarship_email(student["email"], student["name"])

    if email_sent:
        return {"status": "success", "message": f"Scholarship form reminder sent to {student['email']}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send email")
    
# 🔹 Email Sending Function
def send_email(to_email, subject, message):
    try:
        msg = MIMEMultipart()
        msg["From"] = SMTP_EMAIL
        msg["To"] = to_email
        msg["Subject"] = subject
        msg.attach(MIMEText(message, "plain"))

        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SMTP_EMAIL, SMTP_PASSWORD)
        server.sendmail(SMTP_EMAIL, to_email, msg.as_string())
        server.quit()
        return True
    except Exception as e:
        logging.error(f"❌ Email sending failed: {e}")
        return False

# 🔹 Student Promotion Model
class StudentPromotion(BaseModel):
    student_id: str
    new_year: str  # SE, TE, BE

# ✅ API: Get Student Promotion Details
@app.get("/get_student_promotion")
async def get_student_promotion():
    try:
        students = await students_collection.find({}, {"_id": 0, "student_id": 1, "name": 1, "email": 1, "year": 1, "result_updated": 1,"department":1}).to_list(length=None)

        return JSONResponse(content={"status": "success", "students": students}, status_code=200)

    except Exception as e:
        logging.error(f"❌ Error fetching student promotion details: {e}")
        return JSONResponse(content={"status": "error", "message": str(e)}, status_code=500)

# ✅ API: Send Result Update Reminder Email
@app.post("/send_result_reminder")
async def send_result_reminder(data: dict):
    student_id = data.get("student_id")
    student = await students_collection.find_one({"student_id": student_id}, {"_id": 0, "email": 1, "name": 1, "result_updated": 1})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    if student.get("result_updated", False):
        return {"status": "info", "message": "Result already updated"}

    email_sent = send_email(student["email"], "Result Update Reminder", f"Hello {student['name']},\n\nPlease update your result to be eligible for promotion.\n\nThank you.")

    if email_sent:
        logging.info(f"📧 Reminder Email sent to {student['email']}")
        return {"status": "success", "message": f"Result update reminder sent to {student['email']}"}
    else:
        raise HTTPException(status_code=500, detail="Failed to send email")

# ✅ API: Promote Student to Next Year
@app.post("/promote_student")
async def promote_student(data: StudentPromotion):
    student = await students_collection.find_one({"student_id": data.student_id})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    if not student.get("result_updated", False):
        raise HTTPException(status_code=400, detail="Student result not updated, promotion not allowed")

    await students_collection.update_one(
        {"student_id": data.student_id},
        {"$set": {"year": data.new_year}}
    )

    logging.info(f"✅ Student {student['name']} promoted to {data.new_year}")
    return {"status": "success", "message": f"Student {student['name']} promoted to {data.new_year}"}

# 🔹 Email Sending Function
def send_update_email(email, name, changes, admin):
    try:
        change_text = "\n".join([f"- {key}: {value['old']} → {value['new']}" for key, value in changes.items()])

        msg = MIMEMultipart()
        msg["From"] = SMTP_EMAIL
        msg["To"] = email
        msg["Subject"] = "🔔 Student Profile Updated"
        msg["Reply-To"] = SMTP_EMAIL  # Allows students to reply to admin

        email_body = f"""
        Hello {name},

        Your student profile has been updated with the following changes:

        {change_text}

        If you have any concerns, please contact the admin: {admin}.

        Regards,
        Admin Team
        """
        msg.attach(MIMEText(email_body, "plain"))

        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SMTP_EMAIL, SMTP_PASSWORD)
        server.sendmail(SMTP_EMAIL, email, msg.as_string())

        logging.info(f"📧 Update Email sent to {email}")
        return True
    except Exception as e:
        logging.error(f"❌ Email sending failed: {e}")
        return False
    finally:
        server.quit()  # Ensures connection is closed

# ✅ API: Fetch All Students
@app.get("/get_students")
async def get_students(skip: int = 0, limit: int = 10):
    students = await students_collection.find({}, {"_id": 0}).skip(skip).limit(limit).to_list(length=limit)
    
    if not students:
        return {"status": "error", "message": "No students found"}
    
    return {"status": "success", "students": students}


@app.post("/update_student")
async def update_student(request: Request, data: dict = Body(...)):
    logging.info(f"Received update request: {await request.json()}")  # Logging instead of print

    updated_data = data.get("updated_data")
    student_id = updated_data.get("student_id") if updated_data else None
    admin = data.get("admin")

    if not student_id or not updated_data:
        raise HTTPException(status_code=400, detail="Missing student_id or updated_data")

    student = await students_collection.find_one({"student_id": student_id})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    # Track Changes
    changes = {}
    for key, new_value in updated_data.items():
        old_value = student.get(key)
        if old_value != new_value and not (old_value is None and new_value is None):
            changes[key] = {"old": old_value, "new": new_value}

    if changes:
        update_result = await students_collection.update_one(
            {"student_id": student_id},
            {"$set": updated_data}
        )

        if update_result.modified_count == 0:
            raise HTTPException(status_code=500, detail="Database update failed")

        email_sent = send_update_email(student["email"], student["name"], changes, admin)

        return {
            "status": "success",
            "message": "Student details updated",
            "changes": changes,
            "email_sent": email_sent
        }

    return {"status": "info", "message": "No changes detected"}

# 📌 Fetch All Students with Documents
@app.get("/get_students")
async def get_students():
    students = await students_collection.find({}, {"_id": 0}).to_list(length=None)

    if not students:
        raise HTTPException(status_code=404, detail="No students found")
    
    return {"status": "success", "students": students}

# 📌 Send Document Query to a Student
@app.post("/send_document_query")
async def send_document_query(query: DocumentQuery):
    student = await students_collection.find_one({"student_id": query.student_id})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    query_data = {
        "student_id": query.student_id,
        "query_type": query.query_type,
        "comment": query.comment,
        "status": "Pending"
    }

    await queries_collection.insert_one(query_data)

    return {"status": "success", "message": "Query sent successfully"}

# Faculty Model
class Faculty(BaseModel):
    name: str
    employee_id: str
    department: str
    designation: str
    gender: str
    experience: int
    email: EmailStr
    phone: str
    salary: float
    qualification: str
    specialization: str
    password: str

# Function to Send Credentials via Email
def send_credentials(email, emp_id, password):
    try:
        msg = MIMEText(f"Hello,\n\nYour Employee ID: {emp_id}\nYour Password: {password}\n\nLogin to the system using these credentials.")
        msg["Subject"] = "Your Faculty Login Credentials"
        msg["From"] = SMTP_EMAIL
        msg["To"] = email

        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SMTP_EMAIL, SMTP_PASSWORD)
        server.sendmail(SMTP_EMAIL, email, msg.as_string())
        server.quit()
        return True
    except Exception as e:
        print("Email Error:", e)
        return False

# API Endpoint to Add Faculty
@app.post("/add_faculty")
async def add_faculty(faculty: Faculty):
    print(f"Received faculty data: {faculty}")  # Debugging

    # Check if email already exists
    existing_faculty = await faculty_collection.find_one({"email": faculty.email})
    if existing_faculty:
        raise HTTPException(status_code=400, detail="Faculty with this email already exists")

    # Insert faculty data into MongoDB
    faculty_dict = faculty.dict()
    faculty_dict["_id"] = str(ObjectId())  # Convert ObjectId to string
    await faculty_collection.insert_one(faculty_dict)

    return {"message": "Faculty added successfully", "employee_id": faculty.employee_id, "password": faculty.password}

# API Endpoint to Fetch All Faculty
@app.get("/get_faculty")
async def get_faculty():
    faculty_list = await faculty_collection.find().to_list(None)
    return {"faculty": faculty_list}

# ✅ TEST ROUTE
@app.get("/test")
async def test_route():
    return {"status": "success", "message": "API is working!"}

@app.get("/faculty/all")
async def get_all_faculty():
    try:
        # Fetching all faculty details (excluding _id)
        faculty_list = await faculty_collection.find({}, {"_id": 0}).to_list(length=None)

        if not faculty_list:
            raise HTTPException(status_code=404, detail="No faculty found")

        return faculty_list

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/faculty/get_all_leaves")
async def get_all_leaves():
    """Fetch all faculty leave requests from MongoDB"""
    leaves_cursor = faculty_leaves_collection.find({}, {"_id": 0})  
    leaves = await leaves_cursor.to_list(length=None)  # Convert cursor to list
    return leaves

def convert_objectid(doc):
    #Convert MongoDB document ObjectId to string for JSON serialization
    if doc and "_id" in doc:
        doc["_id"] = str(doc["_id"])
    return doc

# Update Leave Status API
@app.put("/faculty/update_leave")
async def update_leave_status(request: LeaveUpdate):
    print(f"Received Data: {request.dict()}")  # Debugging

    # Debug: Check if ANY leave exists for this employee_id
    leave_check = await faculty_leaves_collection.find_one({"employee_id": request.employee_id})
    print(f"Any Leave Found for Employee? {leave_check}")  

    # If no leave request exists at all, return 404
    if not leave_check:
        raise HTTPException(status_code=404, detail=f"No leave request found for employee_id {request.employee_id}")

    # Check if a "Pending" leave request exists
    leave_record = await faculty_leaves_collection.find_one({
        "employee_id": request.employee_id,
        "status": "Pending"  # ✅ Only update pending leave requests
    })
    print(f"Pending Leave Record: {leave_record}")  

    if not leave_record:
        raise HTTPException(status_code=404, detail=f"No pending leave request found for employee_id {request.employee_id}")

    # Update Leave Status
    result = await faculty_leaves_collection.update_one(
        {"_id": leave_record["_id"]},  # ✅ Match specific leave request by ID
        {"$set": {"status": request.status}}
    )

    print(f"Update Result: {result.modified_count}")  # Debugging

    if result.modified_count == 0:
        raise HTTPException(status_code=400, detail="Leave status update failed")

    # Fetch Updated Data and Return
    updated_leave = await faculty_leaves_collection.find_one({"_id": leave_record["_id"]})
    return {
        "message": "Leave status updated successfully",
        "updated_leave": convert_objectid(updated_leave)
    }

    
