# 🎓 ERP System

## 📌 Overview
This is a **Student ERP System** built using **Flutter (Frontend)**, **FastAPI (Backend)**, and **MongoDB (Database)**.  
It manages student, faculty, and admin functionalities, including **admissions, fees management, student profiles, and authentication**.

## 🚀 Tech Stack
- **Frontend:** Flutter  
- **Backend:** FastAPI (Python)  
- **Database:** MongoDB  
- **Authentication:** Role-based login (Admin, Student, Faculty)  

## 🏗️ Project Structure
```plaintext
erp/
│── lib/
│   ├── admin/         # Admin module (signup, login, student management)
│   ├── student/       # Student module (profile, fees, attendance)
│   ├── faculty/       # Faculty module (if required)
│   ├── main.dart      # Main entry point for Flutter app
│── backend/
│   ├── main.py        # FastAPI backend entry point
│   ├── admin.py       # Admin APIs
│   ├── student.py     # Student APIs
│── database/
│   ├── studentERP/    # MongoDB database structure
│── README.md          # Project documentation
│── requirements.txt   # Backend dependencies
```

## ✨ Features
✅ **Admin Panel**  
- Admin login/signup  
- Student admission  
- Fees management  

✅ **Student Portal**  
- Profile & Timetable  
- Fee payment with receipt printing  
- Attendance tracking  

✅ **Role-Based Authentication**  
- Admin, Student, and Faculty login  
- Data stored securely in MongoDB  

## 🔧 Setup Instructions

### 1️⃣ **Backend Setup (FastAPI)**
```sh
cd backend
pip install -r requirement.txt
uvicorn main:app --reload
```

### 2️⃣ **Frontend Setup (Flutter)**
```sh
cd erp
flutter pub get
flutter run
```

### 3️⃣ **MongoDB Setup**
Ensure MongoDB is running and update the database connection in `main.py`.

## 📬 API Endpoints

```plaintext
# ADMIN APIs
POST   /admin_signup              # Register a new admin
POST   /admin_login               # Admin login
POST   /admin/admit-student       # Admit a new student

# STUDENT APIs
GET    /get_admitted_student/{email}  # Fetch student details
GET    /student/get-fees/{student_id} # Get student fees details
POST   /student/pay-fees              # Pay student fees
```

## 📌 Future Enhancements
- Faculty module  
- Notifications and event management  
- AI-based student performance tracking  

---

💡 **Contributor:** [Rohan Balsaraf]  
📅 **Project Start Date:** February 2025  
🔗 **Repository:** [https://github.com/RDX463/erp_project.git]  
