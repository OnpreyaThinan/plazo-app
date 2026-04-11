class PrivacyPolicyContent {
  static const String currentVersion = 'v1';

  static String textForLanguage(String language) {
    if (language == 'th') {
      return _thai;
    }
    return _english;
  }

  static const String _thai = '''นโยบายความเป็นส่วนตัวของ PLAZO

อัปเดตล่าสุด: เมษายน 2026

1. ข้อมูลที่เราเก็บ
- ข้อมูลบัญชี เช่น ชื่อและอีเมล
- ข้อมูลการใช้งานในแอป เช่น Tasks และ Exams

2. เราใช้ข้อมูลเพื่ออะไร
- แสดงผลข้อมูลของคุณในแอป
- ซิงก์ข้อมูลระหว่างอุปกรณ์
- ปรับปรุงประสิทธิภาพและประสบการณ์ใช้งาน

3. การเก็บรักษาข้อมูล
- ข้อมูลถูกจัดเก็บใน Firebase และบางส่วนในอุปกรณ์ของคุณ
- เราเก็บข้อมูลเท่าที่จำเป็นต่อการให้บริการ

4. การแชร์ข้อมูล
- เราไม่ขายข้อมูลส่วนบุคคลของคุณ
- เราไม่แชร์ข้อมูลกับ third-party เพื่อการโฆษณา

5. สิทธิของผู้ใช้
- ขอเข้าถึงข้อมูลของคุณได้
- ขอแก้ไข หรือลบบัญชีและข้อมูลที่เกี่ยวข้องได้

6. Security
- ใช้ระบบยืนยันตัวตน Firebase Authentication
- เข้ารหัสข้อมูลระหว่างการรับส่ง และใช้มาตรการป้องกันตามมาตรฐานทั่วไป

7. Contact
หากมีข้อสงสัยเกี่ยวกับความเป็นส่วนตัว ติดต่อได้ที่ support@plazo.app''';

  static const String _english = '''PLAZO Privacy Policy

Last Updated: April 2026

1. Information We Collect
- Account details such as name and email
- In-app academic data such as tasks and exams

2. How We Use Your Data
- Display your data inside the app
- Sync your data across supported devices
- Improve app quality and user experience

3. Data Storage
- Data is stored in Firebase and partly on your device for app usage
- We retain only data required to provide core services

4. Data Sharing
- We do not sell your personal information
- We do not share your personal data with third parties for advertising

5. Your Rights
- You may request access to your personal data
- You may request account and related data deletion

6. Security
- We use Firebase Authentication for secure sign-in
- Data is encrypted in transit and protected using standard safeguards

7. Contact
For privacy concerns, please contact support@plazo.app''';
}