import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';

Future<void> showHelpContactDialog({
  required BuildContext context,
  required String language,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.getCardBackgroundColor(dialogContext),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        AppStrings.get('helpContact', language),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.getTextColor(dialogContext),
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          _content(language),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextColor(dialogContext),
            height: 1.6,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            AppStrings.get('cancel', language),
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(dialogContext),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

String _content(String language) {
  final isThai = language == 'th';
  if (isThai) {
    return '''PLAZO Help / Contact

Last Updated: April 2026

1. FAQ (คำถามที่พบบ่อย)
- เพิ่ม task ยังไง?
  ไปที่แท็บ Add แล้วกรอกรายละเอียดของงาน จากนั้นกดบันทึก
- ลืมรหัสผ่านทำยังไง?
  ไปที่หน้าเข้าสู่ระบบ แล้วเลือก Forgot Password เพื่อรับลิงก์รีเซ็ตรหัสผ่าน

2. Contact ช่องทาง
- Email support: support@plazo.app
- Report a Bug: ใช้อีเมลด้านบนเพื่อแจ้งบั๊กหรือปัญหาการใช้งานที่พบ
- Feedback: ส่งความคิดเห็น ข้อเสนอแนะ หรือสิ่งที่อยากให้ปรับปรุงได้ทางอีเมลเดียวกัน

3. How to Use App
- ไปที่หน้า Home เพื่อดูรายการ task และ exam ทั้งหมด
- ใช้แท็บ Add เพื่อเพิ่มรายการใหม่
- ไปที่ Settings เพื่อจัดการภาษา ธีม และการแจ้งเตือน
- หากต้องการแก้ไขข้อมูลส่วนตัว สามารถทำได้จากหน้า Settings เช่นกัน''';
  }

  return '''PLAZO Help / Contact

Last Updated: April 2026

1. FAQ
- How do I add a task?
  Go to the Add tab, fill in the task details, then save it.
- What if I forgot my password?
  Go to the sign-in screen and tap Forgot Password to receive a reset link.

2. Contact Channels
- Email support: support@plazo.app
- Report a Bug: Use the email above to report bugs or issues you encounter.
- Feedback: Send suggestions, comments, or improvement ideas through the same email channel.

3. How to Use the App
- Go to Home to view all your tasks and exams.
- Use the Add tab to create new items.
- Open Settings to manage language, theme, and notifications.
- You can also update your profile information from Settings.''';
}
