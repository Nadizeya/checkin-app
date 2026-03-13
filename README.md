# แอปพลิเคชันเช็คอินและสะท้อนการเรียนรู้ชั้นเรียนอัจฉริยะ

หลักสูตร: 1305216 การพัฒนาแอปพลิเคชันมือถือ — การสอบกลางภาค

---

## คำอธิบายโปรเจกต์

แอปพลิเคชัน Flutter ที่อนุญาตให้นักศึกษามหาวิทยาลัย:
- เช็คอินเข้าชั้นเรียนโดยใช้ตำแหน่ง GPS + สแกน QR code
- กรอกแบบฟอร์มสะท้อนการเรียนรู้ก่อนชั้นเรียนพร้อมติดตามอารมณ์
- เช็คเอาท์หลังชั้นเรียนพร้อมสะท้อนหลังชั้นเรียน
- ดูประวัติเซสชันและความก้าวหน้า weekly

---

## เทคโนโลยีที่ใช้

| ชั้น | เทคโนโลยี |
|-------|-----------|
| Framework | Flutter (Dart) |
| สแกน QR | mobile_scanner ^5.1.1 |
| GPS | geolocator ^11.0.0 |
| เก็บข้อมูลท้องถิ่น | sqflite ^2.3.3 |
| ID เฉพาะ | uuid ^4.4.0 |
| การเผยแพร่ | Firebase Hosting |

---

## โครงสร้างโปรเจกต์

```
lib/
├── main.dart                  # จุดเริ่มต้นของแอป
├── theme.dart                 # การตั้งค่าสีและธีม
├── db/
│   └── database_helper.dart   # ฐานข้อมูล SQLite
└── screens/
    ├── login_screen.dart      # หน้าล็อกอิน
    ├── home_screen.dart       # หน้าหลักพร้อมสถิติ + นำทาง
    ├── checkin_screen.dart    # กระบวนการเช็คอิน
    ├── finish_screen.dart     # กระบวนการเสร็จชั้นเรียน
    ├── history_screen.dart    # รายการประวัติเซสชัน
    └── progress_screen.dart   # แผนภูมิอารมณ์ + สตรีค
```

---

## คำแนะนำการตั้งค่า

### 1. ข้อกำหนดเบื้องต้น
- Flutter SDK >= 3.0.0
- Android Studio หรือ VS Code
- อุปกรณ์ Android หรือ emulator (API 21+)

### 2. ติดตั้ง dependencies
```bash
flutter pub get
```

### 3. รันแอป
```bash
flutter run
```

### 4. บิลด์สำหรับ release
```bash
flutter build apk --release
```

---

## การตั้งค่า Firebase

### เผยแพร่ไปยัง Firebase Hosting
```bash
# ติดตั้ง Firebase CLI
npm install -g firebase-tools

# ล็อกอิน
firebase login

# เริ่มต้น (เลือก Hosting)
firebase init

# บิลด์ Flutter Web
flutter build web

# เผยแพร่
firebase deploy
```

### การตั้งค่า Firebase Hosting
- โฟลเดอร์ผลลัพธ์บิลด์: `build/web`
- URL ที่เผยแพร่จะเป็น: `https://YOUR-PROJECT-ID.web.app`

---

## สิทธิ์ Android ที่จำเป็น

เพิ่มใน `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## รายงานการใช้ AI

**เครื่องมือที่ใช้:** Claude (Anthropic)

**สิ่งที่ AI ช่วยสร้าง:**
- โครงร่าง UI Flutter เริ่มต้นสำหรับหน้าจอทั้งหมด
- สคีมาฐานข้อมูล SQLite และคลาสช่วยเหลือ
- บูเลอร์เพลตการรวม GPS และ QR code
- การตั้งค่าธีมและระบบสี

**สิ่งที่ฉันแก้ไข / ใช้งานเอง:**
- ลอจิกการตรวจสอบฟอร์มและการจัดการข้อผิดพลาด
- กระบวนการนำทางระหว่างหน้าจอ (เช็คอิน → เสร็จ → หน้าหลัก)
- การคำนวณระยะเวลาเซสชัน
- สถานะการโต้ตอบของตัวเลือกอารมณ์
- ลอจิกการคิวรีข้อมูลสำหรับสถิติ (อารมณ์เฉลี่ย, จำนวนเซสชัน)
- การรวมข้อมูลแผนภูมิอารมณ์ weekly
- ลอจิกไทล์สตรีคการเข้าร่วม (หน้าต่าง 14 วัน)

---

## หน้าจอ

| หน้าจอ | คำอธิบาย |
|--------|-------------|
| ล็อกอิน | การยืนยันตัวตนด้วยรหัสนักศึกษา + รหัสผ่าน |
| หน้าหลัก | สถิติ, เซสชันล่าสุด, ปุ่มเช็คอิน, นำทางด้านล่าง |
| เช็คอิน | GPS + สแกน QR + ฟอร์มสะท้อน + อารมณ์ |
| เสร็จชั้นเรียน | สแกน QR + GPS + เรียนรู้วันนี้ + ข้อเสนอแนะ |
| ประวัติ | รายการเซสชันที่ผ่านมา พร้อมเหรียญตรา |
| ความก้าวหน้า | แผนภูมิแท่งอารมณ์ weekly + สตรีค 14 วัน |
