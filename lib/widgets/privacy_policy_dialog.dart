import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../content/privacy_policy_content.dart';

Future<void> showAppPrivacyPolicyDialog({
  required BuildContext context,
  required String language,
}) {
  final content = PrivacyPolicyContent.textForLanguage(language);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.getCardBackgroundColor(dialogContext),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        AppStrings.get('privacyPolicy', language),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.getTextColor(dialogContext),
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          content,
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