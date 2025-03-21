import smtplib
from bson import ObjectId
from fastapi.responses import JSONResponse
from fastapi import Request, FastAPI, HTTPException
from pydantic import BaseModel, EmailStr
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
from fastapi.middleware.cors import CORSMiddleware
import logging
import random
import string
from typing import Optional
from fastapi import APIRouter

# Initialize FastAPI
app = FastAPI()

admin_router = APIRouter()

app.include_router(admin_router, prefix="/admin")

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
    students_collection = db.students  # Collection for admin-side student records
    logging.info("✅ MongoDB connected successfully!")
except Exception as e:
    logging.error(f"❌ MongoDB connection failed: {e}")

# Password Hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 🏫 Admin Models
class AdminSignup(BaseModel):
    employee_id: str
    password: str
    confirm_password: str

class AdminLogin(BaseModel):
    employee_id: str
    password: str

# 🎓 Student Models
class StudentAdmission(BaseModel):
    name: str
    email: EmailStr
    total_fees: float
    password: str  # New field for student password

class FeePayment(BaseModel):
    student_id: str
    amount_paid: float

# ✅ Function: Generate Student ID
def generate_student_id():
    return f"STU{''.join(random.choices(string.ascii_uppercase + string.digits, k=6))}"

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

# ✅ STUDENT: Admit a Student
@app.post("/admin/admit-student")
async def admit_student(student: StudentAdmission):
    existing_student = await students_collection.find_one({"email": student.email})
    if existing_student:
        raise HTTPException(status_code=400, detail="Student with this email already exists")

    student_id = generate_student_id()
    hashed_password = pwd_context.hash(student.password)

    student_entry = {
        "student_id": student_id,
        "name": student.name,
        "email": student.email,
        "total_fees": student.total_fees,
        "paid_fees": 0,
        "remaining_fees": student.total_fees,
        "password": hashed_password
    }

    await students_collection.insert_one(student_entry)
    
    logging.info(f"✅ Student Admitted: {student.name} | ID: {student_id}")
    return {
        "message": "Student admitted successfully",
        "student_id": student_id
    }

# ✅ STUDENT: Get Admitted Student Details (For Student Login Verification)
@app.get("/get_admitted_student/{email}")
async def get_admitted_student(email: str):
    student = await students_collection.find_one(
        {"email": email},
        {"_id": 0, "password": 0}  # Exclude MongoDB ID & password
    )
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    return student

# ✅ STUDENT: Get Fees Details
@app.get("/student/get-fees/{student_id}")
async def get_fees(student_id: str):
    student = await students_collection.find_one(
        {"student_id": student_id},
        {"_id": 0, "password": 0}  # Exclude MongoDB ID & password
    )
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    return {
        "total_fees": student["total_fees"],
        "paid_fees": student["paid_fees"],
        "remaining_fees": student["remaining_fees"]
    }

# ✅ STUDENT: Pay Fees
@app.post("/student/pay-fees")
async def pay_fees(payment: FeePayment):
    print(f"🔍 Received Payment Request for Student ID: {payment.student_id}")

    student = await students_collection.find_one({"student_id": payment.student_id})
    if not student:
        print("❌ Student not found in database")
        raise HTTPException(status_code=404, detail="Student not found")

    new_paid_fees = student["paid_fees"] + payment.amount_paid
    remaining_fees = max(student["total_fees"] - new_paid_fees, 0)

    await students_collection.update_one(
        {"student_id": payment.student_id},
        {"$set": {"paid_fees": new_paid_fees, "remaining_fees": remaining_fees}}
    )

    print(f"✅ Fees Paid: {payment.amount_paid} | New Remaining: {remaining_fees}")
    
    return {
        "message": "Payment successful",
        "paid_fees": new_paid_fees,
        "remaining_fees": remaining_fees
    }
    
@app.get("/admin/students")
async def get_students():
    try:
        students = await students_collection.find({}, {"_id": 0, "password": 0}).to_list(length=None)
        if not students:
            raise HTTPException(status_code=404, detail="No students found")
        return students
    except Exception as e:
        logging.error(f"❌ Error fetching students: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


# ✅ TEST ROUTE
@app.get("/test")
async def test_route():
    return {"status": "success", "message": "API is working!"}

@app.put("/admin/update_course/{student_id}")
async def update_course(student_id: str, data: dict):
    updated_course = data.get("course")
    if not updated_course:
        return {"error": "Course is required"}
    
    result = students_collection.update_one(
        {"_id": ObjectId(student_id)},
        {"$set": {"course": updated_course}}
    )
    
    if result.modified_count:
        return {"message": "Course updated successfully"}
    return {"error": "Update failed"}   

@app.post("/admin/promote_student/{student_id}")
async def promote_student(student_id: str):
    student = students_collection.find_one({"student_id": student_id})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    if student.get("result_score", 0) < 50:
        raise HTTPException(status_code=400, detail="Student is not eligible for promotion")

    new_level = student.get("academic_level", 1) + 1  # Increment academic level

    students_collection.update_one(
        {"student_id": student_id},
        {"$set": {"academic_level": new_level, "promotion_status": "Promoted"}}
    )

    return {"message": "Student promoted successfully", "new_level": new_level}
