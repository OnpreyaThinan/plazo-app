class PrivacyPolicyContent {
  static const String currentVersion = 'v1';

  static String textForLanguage(String language) {
    if (language == 'th') {
      return _thai;
    }
    return _english;
  }

  static const String _thai = '''นโยบายความเป็นส่วนตัวของ PLAZO

อัปเดตล่าสุด: มีนาคม 2026

1. ข้อมูลที่เราเก็บ
- ข้อมูลบัญชี (ชื่อ, อีเมล)
- ข้อมูลการวางแผนการเรียน (งาน, สอบ)
- ข้อมูลอุปกรณ์ (ประวัติการเข้าสู่ระบบ)
- สถิติการใช้งาน

2. เราใช้ข้อมูลของคุณอย่างไร
- เพื่อให้บริการและพัฒนาบริการ
- เพื่อส่งการแจ้งเตือนที่สำคัญ
- เพื่อความปลอดภัยของบัญชี
- เพื่อปฏิบัติตามข้อกำหนดทางกฎหมาย

3. การจัดเก็บข้อมูล
- ข้อมูลบางส่วนจัดเก็บในอุปกรณ์ของคุณด้วย SharedPreferences
- ข้อมูลบัญชีจัดเก็บอย่างปลอดภัยใน Firebase
- เราไม่ขายข้อมูลส่วนบุคคลของคุณ

4. ความปลอดภัย
- เราใช้ Firebase Authentication สำหรับการเข้าสู่ระบบอย่างปลอดภัย
- ข้อมูลถูกเข้ารหัสระหว่างการรับส่ง
- เราใช้แนวทางความปลอดภัยตามมาตรฐานอุตสาหกรรม

5. สิทธิของคุณ
- คุณสามารถขอข้อมูลของคุณได้
- คุณสามารถลบบัญชีและข้อมูลที่เกี่ยวข้องทั้งหมดได้
- คุณสามารถส่งออกข้อมูลของคุณได้

6. การติดต่อ
หากมีข้อกังวลด้านความเป็นส่วนตัว ติดต่อเราได้ผ่านหน้าตั้งค่าในแอป''';

  static const String _english = '''PLAZO Privacy Policy

Last Updated: March 2026

1. Information We Collect
- Account information (name, email)
- Academic planning data (tasks, exams)
- Device information (login history)
- Usage statistics

2. How We Use Your Data
- Provide and improve our services
- Send important notifications
- Ensure account security
- Comply with legal obligations

3. Data Storage
- Your data is stored locally on your device using SharedPreferences
- Account data is stored securely in Firebase
- We do not sell your personal information

4. Security
- We use Firebase Authentication for secure login
- Data is encrypted in transit
- We implement industry-standard security practices

5. Your Rights
- You can request your data at any time
- You can delete your account and all associated data
- You can export your data

6. Contact
For privacy concerns, contact us through the app settings.''';
}