# Release Signing Checklist

ใช้ checklist นี้ก่อน build release สำหรับ Play Store

## Keystore
- [ ] มีไฟล์ keystore `.jks` จริง
- [ ] เก็บไฟล์ keystore ไว้ในที่ปลอดภัย และสำรองไว้แล้ว
- [ ] จำ `storePassword`, `keyPassword`, `keyAlias` ได้ถูกต้อง

## key.properties
- [ ] คัดลอก `android/key.properties.example` เป็น `android/key.properties`
- [ ] ใส่ค่า `storePassword` ให้ถูกต้อง
- [ ] ใส่ค่า `keyPassword` ให้ถูกต้อง
- [ ] ใส่ค่า `keyAlias` ให้ตรงกับที่สร้างไว้
- [ ] ใส่ `storeFile` ให้ชี้ไปยังไฟล์ `.jks` จริง

## Build Release
- [ ] สั่ง build release ได้ผ่านด้วย `flutter build apk --release`
- [ ] ถ้าจะขึ้น Play Store แบบ AAB ให้ทดสอบ `flutter build appbundle --release`
- [ ] build ผ่านโดยไม่ต้องแก้ signing ซ้ำ

## ตรวจว่าไม่ได้ใช้ debug signing
- [ ] `android/app/build.gradle.kts` ใช้ signing config แบบ release เท่านั้น
- [ ] ไม่มี fallback ไป `debug` signing ใน release build
- [ ] ถ้าไม่มี `android/key.properties` ต้องให้ build fail ทันที

## ก่อนอัปโหลดขึ้น Play Store
- [ ] ทดสอบติดตั้งไฟล์ release บนเครื่องจริงอย่างน้อย 1 เครื่อง
- [ ] เปิดแอปแล้ว login ได้ตามปกติ
- [ ] ตรวจว่าไม่มีข้อความ debug หรือ error แบบ raw โผล่ให้ user เห็น
- [ ] เช็ก versionCode / versionName ให้เพิ่มจากรอบก่อน
- [ ] เตรียม icon, screenshot, privacy policy URL และข้อมูล Data safety ให้ครบ