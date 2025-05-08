import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final FormFieldValidator<String?>? validator;
  final ValueNotifier<bool> passwordVisible;

  const PasswordField({
    super.key,
    required this.labelText,
    this.controller,
    required this.passwordVisible,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: passwordVisible,
      builder: (context, value, child) {
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.visiblePassword,
          obscureText: !value,
          validator: validator,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            suffixIcon: Tooltip(
              message: value ? 'Hide password' : 'Show password',
              child: GestureDetector(
                onTap: () {
                  passwordVisible.value = !value;
                },
                child: Icon(
                  value ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
