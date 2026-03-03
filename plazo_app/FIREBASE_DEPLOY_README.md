# คู่มือ Deploy Firebase Hosting สำหรับ Plazo App

## สิ่งที่เตรียมไว้ให้แล้ว ✓
- ✓ firebase.json (config สำหรับ Firebase Hosting)
- ✓ build/web (Flutter web app ที่ build เรียบร้อยแล้ว)
- ✓ .firebaserc (ต้องแก้ project ID)

## ขั้นตอนที่ต้องทำต่อ:

### 1. ติดตั้ง Node.js และ npm
ดาวน์โหลดจาก: https://nodejs.org/
- แนะนำเวอร์ชัน LTS
- ติดตั้งตามปกติ แล้วรีสตาร์ท PowerShell

### 2. ติดตั้ง Firebase CLI
เปิด PowerShell แล้วรันคำสั่ง:
```powershell
npm install -g firebase-tools
```

### 3. Login Firebase
```powershell
firebase login
```
- เบราว์เซอร์จะเปิดขึ้นมา
- Login ด้วย Google Account ที่มี Firebase project

### 4. สร้าง Firebase Project (ถ้ายังไม่มี)
- ไปที่: https://console.firebase.google.com/
- คลิก "Add project"
- ตั้งชื่อ project (เช่น "plazo-app")
- เปิดใช้งาน Google Analytics (optional)
- จดเอา Project ID ไว้

### 5. แก้ไขไฟล์ .firebaserc
เปิดไฟล์ `.firebaserc` และแก้:
```json
{
  "projects": {
    "default": "plazo-app"
  }
}
```
เปลี่ยน "plazo-app" เป็น Project ID จริงของคุณ

### 6. Deploy!
```powershell
cd "c:\Users\onpre\Downloads\Plazo_app\plazo_app"
firebase deploy --only hosting
```

### 7. เปิดดูเว็บ
หลัง deploy เสร็จ จะได้ URL แบบนี้:
```
https://your-project-id.web.app
```

## คำสั่งที่มีประโยชน์

### Build web ใหม่ และ deploy
```powershell
flutter build web --release
firebase deploy --only hosting
```

### ดูสถานะ hosting
```powershell
firebase hosting:channel:list
```

### Deploy แบบ preview ก่อน
```powershell
firebase hosting:channel:deploy preview
```

## หมายเหตุ
- ไฟล์ที่ deploy อยู่ใน `build/web/`
- ถ้าแก้โค้ด Flutter ต้อง build ใหม่ก่อน deploy
- Firebase Hosting ฟรี 10GB/เดือน และ 360MB/วัน bandwidth

## แก้ปัญหา

### ถ้า firebase command ไม่พบ
รีสตาร์ท PowerShell หลังติดตั้ง Firebase CLI

### ถ้า permission error
เปิด PowerShell แบบ Administrator

### ถ้า build error
```powershell
flutter clean
flutter pub get
flutter build web --release
```
