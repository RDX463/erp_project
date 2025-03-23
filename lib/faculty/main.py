from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from pymongo import MongoClient
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# MongoDB Connection
MONGO_URI = os.getenv( "mongodb://localhost:27017")
client = MongoClient(MONGO_URI)
db = client.studentERP
faculty_collection = db.faculty_db

app = FastAPI()

# Faculty Login Model
class FacultyLogin(BaseModel):
    employee_id: str
    password: str

@app.post("/faculty/login")
def faculty_login(login_data: FacultyLogin):
    faculty = faculty_collection.find_one({"employee_id": login_data.employee_id})

    if not faculty:
        raise HTTPException(status_code=404, detail="Employee ID not found")

    if faculty["password"] != login_data.password:
        raise HTTPException(status_code=401, detail="Incorrect password")

    return {"message": "Login successful", "faculty_name": faculty["name"]}

# Run the FastAPI server: uvicorn main:app --reload
