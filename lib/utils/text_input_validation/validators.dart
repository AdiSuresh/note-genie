import 'package:flutter/material.dart';

typedef TextInputValidator = FormFieldValidator<String>;

class Validators {
  static TextInputValidator nonEmptyFieldValidator = (value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  };
}
