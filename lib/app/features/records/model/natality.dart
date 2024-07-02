import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sentry/app/features/records/model/data_record.dart';

class Natality implements DataRecord {
  static const natalityString = "natality";
  final String userId;
  final DateTime timestamp;
  @override
  final DateTime date;
  @override
  final String gender;
  final String barangay;
  final int motherAgeGroup;
  final int fatherAgeGroup;
  final String submittedBy;

  Natality(
      {required this.userId,
      required this.timestamp,
      required this.date,
      required this.gender,
      required this.barangay,
      required this.motherAgeGroup,
      required this.fatherAgeGroup,
      required this.submittedBy});

  Map<String, dynamic> toFirestore() {
    final result = <String, dynamic>{};

    result.addAll({'userId': userId});
    result.addAll({'timestamp': timestamp.millisecondsSinceEpoch});
    result.addAll({'date': date.millisecondsSinceEpoch});
    result.addAll({'gender': gender});
    result.addAll({'barangay': barangay});
    result.addAll({'motherAgeGroup': motherAgeGroup});
    result.addAll({'fatherAgeGroup': fatherAgeGroup});
    result.addAll({'submittedBy': submittedBy});

    return result;
  }

  factory Natality.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final map = snapshot.data();
    return Natality(
      userId: map?['userId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map?['timestamp']),
      date: DateTime.fromMillisecondsSinceEpoch(map?['date']),
      gender: map?['gender'] ?? '',
      barangay: map?['barangay'] ?? '',
      motherAgeGroup: map?['motherAgeGroup'] ?? -1,
      fatherAgeGroup: map?['fatherAgeGroup'] ?? -1,
      submittedBy: map?['submittedBy'] ?? '',
    );
  }

  Natality copyWith({
    String? userId,
    DateTime? timestamp,
    DateTime? date,
    String? gender,
    String? barangay,
    int? motherAgeGroup,
    int? fatherAgeGroup,
    String? submittedBy,
  }) {
    return Natality(
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      date: date ?? this.date,
      gender: gender ?? this.gender,
      barangay: barangay ?? this.barangay,
      motherAgeGroup: motherAgeGroup ?? this.motherAgeGroup,
      fatherAgeGroup: fatherAgeGroup ?? this.fatherAgeGroup,
      submittedBy: submittedBy ?? this.submittedBy,
    );
  }

  @override
  int get diseaseAgeGroup => 0;
}
