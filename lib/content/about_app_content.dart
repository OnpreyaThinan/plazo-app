import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';

Future<void> showAppAboutDialog({
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
        AppStrings.get('aboutApp', language),
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
    return '''PLAZO About App

Last Updated: April 2026

1. App Name
- PLAZO

2. Version
- v1.0.0

3. Description
- PLAZO คือแอปผู้ช่วยสำหรับการจัดการการเรียนและชีวิตนักศึกษา
- ช่วยให้ผู้ใช้บันทึก Task และ Exam ไว้ในที่เดียว
- ดูรายการที่ใกล้ถึงกำหนดและติดตามสิ่งที่ต้องทำได้ง่ายขึ้น
- จัดระเบียบข้อมูลสำคัญของการเรียนให้เป็นระบบ
- ปรับภาษา ธีม และการแจ้งเตือนได้จากหน้า Settings

4. Terms & Conditions
- การใช้งาน PLAZO หมายถึงคุณยอมรับว่าจะใช้แอปเพื่อการจัดการงานเรียนส่วนบุคคลเท่านั้น
- ข้อมูลที่บันทึกไว้ในแอปเป็นความรับผิดชอบของผู้ใช้เอง
- ผู้ใช้ควรตรวจสอบข้อมูลก่อนบันทึกทุกครั้ง
- เราอาจปรับปรุงฟีเจอร์หรือเนื้อหาในแอปเป็นระยะเพื่อให้บริการดีขึ้น''';
  }

  return '''PLAZO About App

Last Updated: April 2026

1. App Name
- PLAZO

2. Version
- v1.0.0

3. Description
- PLAZO is a study companion app designed to help users manage academic and daily study tasks in one place.
- You can add and track tasks and exams.
- You can review upcoming items and keep your study plan organized.
- You can manage language, theme, and reminder settings from Settings.
- The app is built to make study planning simple, clear, and more organized.

4. Terms & Conditions
- By using PLAZO, you agree to use the app for personal academic organization only.
- You are responsible for the information you save in the app.
- You should review your entries before saving them.
- We may update app features or content from time to time to improve the service.''';
}
