import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sentry/app/features/records/model/data_record.dart';

class Mortality implements DataRecord {
  static const mortalityString = "mortality";
  final String userId;
  final DateTime timestamp;
  @override
  final DateTime date;
  @override
  final String gender;
  final String barangay;
  final String submittedBy;
  final int diseaseAgeGroup;
  final String causeOfDeath;

  Mortality(
      {required this.userId,
      required this.timestamp,
      required this.date,
      required this.gender,
      required this.barangay,
      required this.diseaseAgeGroup,
      required this.causeOfDeath,
      required this.submittedBy});

  Map<String, dynamic> toFirestore() {
    final result = <String, dynamic>{};

    result.addAll({'userId': userId});
    result.addAll({'timestamp': timestamp.millisecondsSinceEpoch});
    result.addAll({'date': date.millisecondsSinceEpoch});
    result.addAll({'gender': gender});
    result.addAll({'barangay': barangay});
    result.addAll({'diseaseAgeGroup': diseaseAgeGroup});
    result.addAll({'causeOfDeath': causeOfDeath});
    result.addAll({'submittedBy': submittedBy});

    return result;
  }

  factory Mortality.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final map = snapshot.data();
    return Mortality(
      userId: map?['userId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map?['timestamp']),
      date: DateTime.fromMillisecondsSinceEpoch(map?['date']),
      gender: map?['gender'] ?? '',
      barangay: map?['barangay'] ?? '',
      diseaseAgeGroup: map?['diseaseAgeGroup'] ?? '',
      causeOfDeath: map?['causeOfDeath'] ?? '',
      submittedBy: map?['submittedBy'] ?? '',
    );
  }

  Mortality copyWith({
    String? userId,
    DateTime? timestamp,
    DateTime? date,
    String? gender,
    String? barangay,
    String? submittedBy,
    int? diseaseAgeGroup,
    String? causeOfDeath,
  }) {
    return Mortality(
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      date: date ?? this.date,
      gender: gender ?? this.gender,
      barangay: barangay ?? this.barangay,
      submittedBy: submittedBy ?? this.submittedBy,
      diseaseAgeGroup: diseaseAgeGroup ?? this.diseaseAgeGroup,
      causeOfDeath: causeOfDeath ?? this.causeOfDeath,
    );
  }
}
