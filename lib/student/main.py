from fastapi import FastAPI, HTTPException, Request
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime
import logging

app = FastAPI()

# ✅ MongoDB Connection
client = AsyncIOMotorClient("mongodb://localhost:27017")
db = client.studentERP
students_collection = db.students
student_profiles = db.student_profiles
fees_collection = db.fees  # Collection for storing student fees

# ✅ Pydantic Models
class LoginRequest(BaseModel):
    name: str
    email: EmailStr

class StudentSignup(BaseModel):
    email: EmailStr
    password: str

class StudentProfile(BaseModel):
    email: str
    full_name: Optional[str] = ""
    branch: Optional[str] = ""
    dob: Optional[str] = None
    phone: Optional[str] = ""
    father_name: Optional[str] = ""
    mother_name: Optional[str] = ""
    semester: Optional[str] = ""
    gender: Optional[str] = ""
    address: Optional[str] = ""
    profile_picture: Optional[str] = None

class StudentFees(BaseModel):
    email: str
    academic_year: str
    total_fees: float = 0
    paid_fees: float = 0
    remaining_fees: float = 0
    exam_fees: float = 0
    paid_exam_fees: float = 0

# ✅ Helper Function: Calculate Age from DOB
def calculate_age(dob: Optional[str]) -> int:
    if dob:
        try:
            birth_date = datetime.strptime(dob, "%Y-%m-%d")
            today = datetime.today()
            return today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format, use YYYY-MM-DD")
    return 0

# ✅ Student Signup API
@app.post("/student/signup")
async def signup(request: Request):
    try:
        data = await request.json()
        signup_data = StudentSignup(**data)

        existing_user = await students_collection.find_one({"email": signup_data.email})
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")

        await students_collection.insert_one({
            "email": signup_data.email,
            "password": signup_data.password  # Ideally, hash the password
        })

        return {"message": "Signup successful"}

    except Exception as e:
        logging.error(f"Error during signup: {str(e)}")
        raise HTTPException(status_code=400, detail="Invalid request format")

# ✅ Student Login API
@app.post("/student/login")
async def login(request: LoginRequest):
    student = await students_collection.find_one({"email": request.email})
    if not student:
        raise HTTPException(status_code=400, detail="Student not found")
    if student.get("name") != request.name:
        raise HTTPException(status_code=400, detail="Incorrect name")
    return {"message": "Login successful"}

# ✅ Get Student Profile API
@app.get("/get_student_profile")
async def get_student_profile(email: str):
    student = await students_collection.find_one({"email": email})
    profile = await student_profiles.find_one({"email": email})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    profile_data = profile or {}

    return {
        "email": student.get("email", ""),
        "full_name": profile_data.get("full_name", ""),
        "branch": profile_data.get("branch", ""),
        "dob": profile_data.get("dob", ""),
        "age": calculate_age(profile_data.get("dob")),
        "phone": profile_data.get("phone", ""),
        "father_name": profile_data.get("father_name", ""),
        "mother_name": profile_data.get("mother_name", ""),
        "semester": profile_data.get("semester", ""),
        "gender": profile_data.get("gender", ""),
        "address": profile_data.get("address", ""),
        "profile_picture": profile_data.get("profile_picture", ""),
    }

# ✅ Update Student Profile API
@app.post("/update_student_profile")
async def update_student_profile(request: Request):
    try:
        data = await request.json()
        profile_data = StudentProfile(**data)

        # Convert Pydantic model to dictionary and remove `None` values
        update_data = {k: v for k, v in profile_data.dict(exclude_unset=True).items() if v is not None}

        # Check if profile exists
        existing_profile = await student_profiles.find_one({"email": profile_data.email})

        if existing_profile:
            await student_profiles.update_one(
                {"email": profile_data.email},
                {"$set": update_data}
            )
            return {"message": "Profile updated successfully"}
        else:
            await student_profiles.insert_one(update_data)
            return {"message": "Profile created successfully"}

    except Exception as e:
        logging.error(f"Error updating profile: {str(e)}")
        raise HTTPException(status_code=400, detail="Error updating profile")


# ✅ Get Student Name by Email API
@app.get("/get_student_name_by_email")
async def get_student_name_by_email(email: str):
    student = await student_profiles.find_one({"email": email})
    if student:
        return {"full_name": student["full_name"]}
    raise HTTPException(status_code=404, detail="Student not found")

# ✅ Get Student Fees API
@app.get("/get_student_fees")
async def get_student_fees(email: str, academic_year: str):
    student = await students_collection.find_one({"email": email})

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    fees_data = student.get("fees", {}).get(academic_year, {})

    # Return default values if no data exists
    return {
        "total_fees": fees_data.get("total_fees", 0),
        "paid_fees": fees_data.get("paid_fees", 0),
        "remaining_fees": fees_data.get("remaining_fees", 0)
    }

# ✅ Admin Updates Student Fees API
@app.post("/update_student_fees")
async def update_student_fees(request: Request):
    body = await request.json()
    fees_data = StudentFees(**body)

    if not await student_profiles.find_one({"email": fees_data.email}):
        raise HTTPException(status_code=404, detail="Student not found")

    await fees_collection.update_one(
        {"email": fees_data.email, "academic_year": fees_data.academic_year},
        {"$set": fees_data.dict()},
        upsert=True
    )

    return {"message": "Student fees updated successfully"}

# ✅ Make Fee Payment API
@app.post("/pay_fees")
async def pay_fees(request: Request):
    body = await request.json()
    email, academic_year, amount = body.get("email"), body.get("academic_year"), body.get("amount")

    fees = await fees_collection.find_one({"email": email, "academic_year": academic_year})
    if not fees:
        raise HTTPException(status_code=404, detail="Fees record not found")

    updated_paid_fees = fees["paid_fees"] + amount
    updated_remaining_fees = max(fees["total_fees"] - updated_paid_fees, 0)

    await fees_collection.update_one(
        {"email": email, "academic_year": academic_year},
        {"$set": {"paid_fees": updated_paid_fees, "remaining_fees": updated_remaining_fees}}
    )

    return {"message": "Fee payment successful", "paid_fees": updated_paid_fees, "remaining_fees": updated_remaining_fees}

# ✅ Generate Receipt API
@app.get("/generate_receipt")
async def generate_receipt(email: str, academic_year: str):
    fees = await fees_collection.find_one({"email": email, "academic_year": academic_year}, {"_id": 0})
    if not fees:
        raise HTTPException(status_code=404, detail="Fees record not found")
    return {"receipt": f"Receipt for {email} - {academic_year}", **fees}

# ✅ Get All Student Profiles API
@app.get("/all_student_profiles", response_model=List[dict])
async def get_all_students():
    try:
        students_cursor = student_profiles.find({}, {"_id": 0})
        students = [student async for student in students_cursor]

        if not students:
            raise HTTPException(status_code=404, detail="No student profiles found")

        return students
    except Exception as e:
        logging.error(f"Error fetching students: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching students: {str(e)}")
