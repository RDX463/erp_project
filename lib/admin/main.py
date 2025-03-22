import smtplib
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

# ✅ TEST ROUTE
@app.get("/test")
async def test_route():
    return {"status": "success", "message": "API is working!"}