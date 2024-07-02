import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final DateTime timestamp;
  final String username;
  final String firstname;
  final String lastname;
  final String userId;
  final String email;
  final String barangay;
  final int role;

  static const userString = "user";
  static String getRoleString(int role) {
    if (role == 0) return UserRoles.superadmin.name;
    if (role == 1) return UserRoles.admin.name;
    if (role == 2) return UserRoles.client.name;
    return "-";
  }

  static bool isAdmin(int role) {
    if (role == UserRoles.superadmin.index || role == UserRoles.admin.index) {
      return true;
    }
    return false;
  }

  static bool isSuperAdmin(int role) {
    if (role == UserRoles.superadmin.index) return true;
    return false;
  }

  User(
      {required this.timestamp,
      required this.username,
      required this.firstname,
      required this.lastname,
      required this.userId,
      required this.email,
      required this.barangay,
      required this.role});

  Map<String, dynamic> toFirestore() {
    final result = <String, dynamic>{};
    result.addAll({'timestamp': timestamp.millisecondsSinceEpoch});
    result.addAll({'username': username});
    result.addAll({'firstname': firstname});
    result.addAll({'lastname': lastname});
    result.addAll({'userId': userId});
    result.addAll({'email': email});
    result.addAll({'barangay': barangay});
    result.addAll({'role': role});

    return result;
  }

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final map = snapshot.data()!;
    return User(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      username: map['username'] ?? '',
      firstname: map['firstname'] ?? '',
      lastname: map['lastname'] ?? '',
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      barangay: map['barangay'] ?? '',
      role: map['role']?.toInt() ?? 0,
    );
  }

  User copyWith({
    DateTime? timestamp,
    String? username,
    String? firstname,
    String? lastname,
    String? userId,
    String? email,
    String? barangay,
    int? role,
  }) {
    return User(
      timestamp: timestamp ?? this.timestamp,
      username: username ?? this.username,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      barangay: barangay ?? this.barangay,
      role: role ?? this.role,
    );
  }
}

enum UserRoles { superadmin, admin, client }
