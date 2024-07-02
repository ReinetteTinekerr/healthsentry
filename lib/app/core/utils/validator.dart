import 'package:health_sentry/app/features/accounts/model/user.dart';

bool isValidEmail(String email) {
  final emailRegex = RegExp(r"[a-zA-Z0-9.]+@jones\.jones");
  return emailRegex.hasMatch(email);
}

bool isPasswordValid(String password) {
  const pattern = r".{5,}.";
  return RegExp(pattern).hasMatch(password);
}

bool isValidUsername(String chars) {
  const pattern = r".{5,}.";
  return RegExp(pattern).hasMatch(chars);
}

bool isValidLength(String chars) {
  const pattern = r".{2,}.";
  return RegExp(pattern).hasMatch(chars);
}

bool hasDeletePermission(
    {required String docUserId,
    required String currentUserId,
    required int role}) {
  if (User.isAdmin(role)) {
    return true;
  } else if (UserRoles.client.index == role && docUserId == currentUserId) {
    return true;
  } else {
    return false;
  }
}
