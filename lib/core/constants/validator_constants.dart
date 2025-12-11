

import 'package:flutter/services.dart';

class Validators {
  static String? validateMobile(String value) {
    if (value.isEmpty) return 'Mobile Number is Required';
    if(value.length!=11){
      return 'Enter valid mobile number';
    }
    return null;
  }

  static String? validateName(String value, String type) {
    final RegExp regExp = RegExp(r'^[a-zA-Z ]+$');
    if (value.isEmpty) return '$type is Required';
    if (!regExp.hasMatch(value)) return '$type must contain only letters and spaces';
    return null;
  }

  static String? validateDob(DateTime? date) {
    if (date == null) return 'Date of birth is Required';

    final today = DateTime.now();
    final age = today.year - date.year - ((today.month < date.month || (today.month == date.month && today.day < date.day)) ? 1 : 0);

    if (age < 18) return 'You must be at least 18 years old.';
    return null;
  }

  static String? validateEmail(String value) {
    final RegExp regExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+$");
    if (value.isEmpty) return 'Email is Required';
    if (!regExp.hasMatch(value)) return 'Invalid Email';
    return null;
  }

  static String? validateRequired(String value, String type) {
    if (value.isEmpty) return '$type is Required';
    return null;
  }

  static String? validateCountryCode(String value) {
    final RegExp regExp = RegExp(r'^\d{1,3}$');
    if (value.isEmpty) return 'Country code is Required';
    if (!regExp.hasMatch(value)) return 'Invalid country code';
    return null;
  }

  static String? validatePassword(String value) {
    final RegExp regExp = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    if (value.isEmpty) return 'Password is Required';
    if (!regExp.hasMatch(value)) {
      return 'Password must be at least 8 characters\ninclude upper & lowercase letters and a number.';
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return 'Confirm Password is Required';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  static String? validateDate(String value) {
    final RegExp regExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (value.isEmpty) return 'Date is Required';
    if (!regExp.hasMatch(value)) return 'Please enter a valid date (YYYY-MM-DD)';
    return null;
  }

  static String? validateCardNumber(String value) {
    if (value.isEmpty) return 'Account Number is Required';
    if (value.length < 9) return 'Account Number must be at least 9 digits';
    return null;
  }

  static String? validateConfirmCardNumber(String value1, String value2) {
    if (value1.isEmpty) return 'Account Number is Required';
    if (value1 != value2) return 'Account Numbers do not match';
    return null;
  }

  static String? validatePassengers(String value, String label) {
    if (value.isEmpty) return '$label is Required';
    final intVal = int.tryParse(value);
    if (intVal == null) return '$label must be a number';
    if (intVal > 10) return 'Maximum $label limit is 10';
    return null;
  }

  static String? validatePasswordParent(String value) {
    final RegExp regExp = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>]).{8,}$');
    if (value.isEmpty) return 'Password is Required';
    if (!regExp.hasMatch(value)) {
      return 'Password must be at least 8 characters,\ninclude upper & lowercase letters,\na number, and a special character.';
    }
    return null;
  }

  static String? isValidIFSCode(String value) {
    final RegExp regExp = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (value.isEmpty) return 'Please enter IFSC Code';
    if (!regExp.hasMatch(value)) return 'Please enter a valid IFSC Code';
    return null;
  }


  static String hideDigits(String numberStr) {
    if (numberStr.length <= 4) return numberStr;
    return '•' * (numberStr.length - 4) + numberStr.substring(numberStr.length - 4);
  }

  final textFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    if (newValue.text.isEmpty) return newValue;
    if (oldValue.text.length < newValue.text.length) {
      final newText = newValue.text.replaceFirstMapped(
        RegExp(r'(?<=\s|^)(\w)'),
            (match) => match.group(0)!.toUpperCase(),
      );
      return newValue.copyWith(text: newText);
    }
    return newValue;
  });

  static String getDocumentType(String documentName) {
    final ext = documentName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'doc';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      default:
        return '';
    }
  }
}
