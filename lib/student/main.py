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
    name: str  # Changed to name instead of password
    email: str  # Email field

class StudentSignup(BaseModel):
    email: EmailStr
    password: str

class StudentProfile(BaseModel):
    email: str
    full_name: Optional[str] = ""
    branch: Optional[str] = ""
    dob: Optional[str] = None  # Date of Birth (YYYY-MM-DD)
    phone: Optional[str] = ""
    father_name: Optional[str] = ""
    mother_name: Optional[str] = ""
    semester: Optional[str] = ""
    gender: Optional[str] = ""
    address: Optional[str] = ""
    profile_picture: Optional[str] = None  # Base64 Image String

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
    return 0  # Default if DOB is missing

# ✅ Student Signup API (Keeps existing signup with password)
@app.post("/student/signup")
async def signup(request: Request):
    try:
        data = await request.json()
        print("📩 Received Data:", data)  # Debugging output

        signup_data = StudentSignup(**data)

        existing_user = await students_collection.find_one({"email": signup_data.email})  # Ensure async find
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")

        # ✅ Store the new student with hashed password
        await students_collection.insert_one({
            "email": signup_data.email,
            "password": signup_data.password  # Store password in plain text (for this example, but ideally, hash it)
        })

        return {"message": "Signup successful"}

    except Exception as e:
        print("🚨 Error:", str(e))
        raise HTTPException(status_code=400, detail="Invalid request format")

# ✅ Student Login API (using name and email for login)
@app.post("/student/login")
async def login(request: LoginRequest):
    student = await students_collection.find_one({"email": request.email})  # Ensure you await the result

    if not student:
        raise HTTPException(status_code=400, detail="Student not found")

    # Check if the name matches
    if student["name"] != request.name:
        raise HTTPException(status_code=400, detail="Incorrect name")

    return {"message": "Login successful"}

# ✅ Get Student Profile API
@app.get("/get_student_profile")
async def get_student_profile(email: str):
    # Ensure the database queries are awaited
    student = await students_collection.find_one({"email": email})  # Add await
    profile = await student_profiles.find_one({"email": email})  # Add await

    if not student:
        raise HTTPException(status_code=404, detail="Student not found in students collection")

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

@app.post("/update_student_profile")
async def update_student_profile(request: Request):
    try:
        # Parse the incoming data
        data = await request.json()
        profile_data = StudentProfile(**data)

        # Find the existing profile
        existing_profile = await student_profiles.find_one({"email": profile_data.email})

        if existing_profile:
            # Update the profile if it exists
            await student_profiles.update_one(
                {"email": profile_data.email},
                {"$set": profile_data.dict(exclude_unset=True)}  # Use exclude_unset to avoid overwriting null fields
            )
            return {"message": "Profile updated successfully"}
        else:
            # If profile does not exist, insert a new record
            await student_profiles.insert_one(profile_data.dict())
            return {"message": "Profile created successfully"}

    except Exception as e:
        print("Error:", e)
        raise HTTPException(status_code=400, detail="Error updating profile")

# ✅ Get Student Name by Email API
@app.get("/get_student_name_by_email")
async def get_student_name_by_email(email: str):
    # Fetch the student data from the database using the email
    student = await student_profiles.find_one({"email": email})
    if student:
        return {"full_name": student["full_name"]}
    raise HTTPException(status_code=404, detail="Student not found")

# ✅ Get Student Fees API
@app.get("/get_student_fees")
async def get_student_fees(email: str, academic_year: str):
    # Fetch fees data based on email and academic year
    fees = await fees_collection.find_one({"email": email, "academic_year": academic_year})
    if fees:
        return {
            "total_fees": fees["total_fees"],
            "paid_fees": fees["paid_fees"],
            "remaining_fees": fees["remaining_fees"]
        }
    raise HTTPException(status_code=404, detail="Fees not found")

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
        raise HTTPException(status_code=404, detail="Fees record not found for this student")

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
        raise HTTPException(status_code=404, detail="Fees record not found for this student")

    return {
        "receipt": f"Receipt for {email} - {academic_year}",
        **fees
    }

@app.get("/all_student_profiles", response_model=List[dict])
async def get_all_students():
    try:
        students_cursor = student_profiles.find({}, {"_id": 0})  # Create an async cursor
        
        # Manually iterate over the cursor and collect the data
        students = []
        async for student in students_cursor:
            students.append(student)
        
        if not students:
            raise HTTPException(status_code=404, detail="No student profiles found")
        
        return students  # Return the student data as JSON
    except Exception as e:
        logging.error(f"Error fetching students: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching students: {str(e)}")
