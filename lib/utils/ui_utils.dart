import 'package:flutter/material.dart';

class UiUtils {
  static void dismissKeyboard(
    BuildContext context,
  ) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static Future<dynamic> showEditTitleDialog({
    required String title,
    required BuildContext context,
    required TextEditingController titleCtrl,
    required VoidCallback onOk,
    required VoidCallback onCancel,
    String? Function(String?)? validator,
    GlobalKey<FormState>? formKey,
  }) {
    final textField = TextFormField(
      controller: titleCtrl,
      autofocus: true,
      validator: validator,
    );
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Rename document',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (formKey == null)
                textField
              else
                Form(
                  key: formKey,
                  child: textField,
                ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onOk,
                    child: const Text(
                      'OK',
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text(
                      'Cancel',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
