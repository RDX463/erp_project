from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from pymongo import MongoClient
from dotenv import load_dotenv
from typing import List, Optional
from datetime import datetime
import os

# Load environment variables from .env file
load_dotenv()

# MongoDB Connection
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")  # Default to localhost if not found
client = MongoClient(MONGO_URI)
db = client.studentERP
faculty_collection = db.faculty_db  # Ensure correct collection name
faculty_leaves_collection = db.faculty_leaves

app = FastAPI()

# Faculty Login Model
class FacultyLogin(BaseModel):
    employee_id: str
    password: str

# Faculty Data Model
class FacultyUpdateSchema(BaseModel):
    faculty_name: str
    email: str
    phone: str
    department: str
    address: Optional[str] = None
    dob: Optional[str] = None
    gender: str
    teaching_years: List[str]
    subjects: List[str]
    
class LeaveRequest(BaseModel):
    employee_id: str
    leave_date: str
    days: int
    reason: str
    status: str = "Pending"  # Default status

# Faculty Login Endpoint
@app.post("/faculty/login")
def faculty_login(login_data: FacultyLogin):
    faculty = faculty_collection.find_one({"employee_id": login_data.employee_id})

    if not faculty:
        raise HTTPException(status_code=404, detail="Employee ID not found")

    if faculty.get("password") != login_data.password:
        raise HTTPException(status_code=401, detail="Incorrect password")

    # If faculty_name is empty, use "name" field instead
    faculty_name = faculty.get("faculty_name", "").strip()
    if not faculty_name:  
        faculty_name = faculty.get("name", "Unknown Faculty")  # Fallback to "name" field

    return {"message": "Login successful", "faculty_name": faculty_name}

# Fetch Faculty Profile
@app.get("/faculty/profile/{employee_id}")
def get_faculty_profile(employee_id: str):
    faculty = faculty_collection.find_one({"employee_id": employee_id}, {"_id": 0})
    
    if not faculty:
        raise HTTPException(status_code=404, detail="Faculty not found")

    # If faculty_name is empty, fallback to "name" field
    if not faculty.get("faculty_name"):
        faculty["faculty_name"] = faculty.get("name", "Unknown Faculty")

    return faculty

# Add Faculty with Validation
@app.post("/faculty/add")
def add_faculty(faculty: FacultyUpdateSchema):
    faculty_data = faculty.dict()

    if not faculty_data.get("faculty_name") or faculty_data["faculty_name"].strip() == "":
        raise HTTPException(status_code=400, detail="Faculty name is required")

    faculty_collection.insert_one(faculty_data)
    return {"message": "Faculty added successfully"}

# Update Faculty Profile
@app.put("/faculty/profile/update/{employee_id}")
async def update_faculty_profile(employee_id: str, request: Request):
    try:
        data = await request.json()
        print("Received Data:", data)  # Debugging request payload

        if "faculty_name" in data and (not data["faculty_name"] or data["faculty_name"].strip() == ""):
            raise HTTPException(status_code=400, detail="Faculty name cannot be empty")

        update_data = {k: v for k, v in data.items() if v is not None}  # Remove None values

        result = faculty_collection.update_one(
            {"employee_id": employee_id}, {"$set": update_data}
        )

        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Faculty not found")

        return {"message": "Profile updated successfully"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

# Apply for leave
@app.post("/faculty/apply_leave")
async def apply_leave(request: LeaveRequest):
    try:
        leave_date = datetime.strptime(request.leave_date, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")

    faculty_leaves_collection.insert_one(request.dict())

    return {"message": "Leave request submitted successfully!"}

# Get all leave requests for a specific faculty member
@app.get("/faculty/get_leaves/{employee_id}")
async def get_faculty_leaves(employee_id: str):
    leaves = list(faculty_leaves_collection.find({"employee_id": employee_id}, {"_id": 0}))
    return leaves