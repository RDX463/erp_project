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
from datetime import datetime

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

# ✅ TEST ROUTE
@app.get("/test")
async def test_route():
    return {"status": "success", "message": "API is working!"}
