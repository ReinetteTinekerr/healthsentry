import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sentry/app/core/local_storage/local_data.dart';
import 'package:health_sentry/app/core/utils/date_format.dart';
import 'package:health_sentry/app/core/utils/functions.dart';
import 'package:health_sentry/app/features/records/model/data_record.dart';
import 'package:health_sentry/app/features/records/model/morbidity.dart';
import 'package:health_sentry/app/features/records/model/mortality.dart';
import 'package:health_sentry/app/features/records/model/natality.dart';
import 'package:intl/intl.dart';

enum SummaryType {
  increment,
  decrement,
}

class RecordsRepository {
  final FirebaseFirestore db;
  final summaryCollection = "summary";

  RecordsRepository({required this.db});

  Future<CollectionReference<Natality>> addNewNatality(
      Natality natality) async {
    final natalityRef = db.collection(Natality.natalityString).withConverter(
          fromFirestore: Natality.fromFirestore,
          toFirestore: (Natality natality, options) => natality.toFirestore(),
        );
    await natalityRef.add(natality);

    return natalityRef;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSummaryByYear(
      {required DateTime date}) async {
    final yearString = DateFormat("yyyy").format(date);
    final summaryRef = db.collection(summaryCollection).doc(yearString);
    return await summaryRef.get();
  }

  Future<void> updateSummary(
      {required DataRecord dataRecord,
      SummaryType type = SummaryType.increment}) async {
    final yearString = DateFormat("yyyy").format(dataRecord.date);
    final monthSring = DateFormat("MMMM").format(dataRecord.date);
    final recordName = getRecordName(dataRecord);
    final fieldValue = type == SummaryType.increment ? 1 : -1;

    final summaryRef = db.collection(summaryCollection).doc(yearString);

    if (dataRecord is Natality) {
      final natality = dataRecord;
      await summaryRef.set(
          {
            monthSring: {
              recordName: {
                "total": FieldValue.increment(fieldValue),
                "barangay": {
                  natality.barangay.toUpperCase(): {
                    "total": FieldValue.increment(fieldValue),
                    LocalData.findParentsAgeGroupKey(natality.motherAgeGroup): {
                      natality.gender: FieldValue.increment(fieldValue),
                    }
                  }
                },
              }
            }
          },
          SetOptions(
            merge: true,
          ));
    } else if (dataRecord is Mortality) {
      final mortality = dataRecord;
      await summaryRef.set(
          {
            monthSring: {
              recordName: {
                "total": FieldValue.increment(fieldValue),
                "barangay": {
                  mortality.barangay.toUpperCase(): {
                    "total": FieldValue.increment(fieldValue),
                    mortality.causeOfDeath: {
                      LocalData.findDiseaseAgeGroupKey(
                          mortality.diseaseAgeGroup): {
                        mortality.gender: FieldValue.increment(fieldValue),
                      }
                    },
                  }
                },
              }
            }
          },
          SetOptions(
            merge: true,
          ));
    } else if (dataRecord is Morbidity) {
      final morbidity = dataRecord;
      await summaryRef.set(
          {
            monthSring: {
              recordName: {
                "total": FieldValue.increment(fieldValue),
                "barangay": {
                  morbidity.barangay.toUpperCase(): {
                    "total": FieldValue.increment(fieldValue),
                    morbidity.disease: {
                      LocalData.findDiseaseAgeGroupKey(
                          morbidity.diseaseAgeGroup): {
                        morbidity.gender: FieldValue.increment(fieldValue),
                      }
                    },
                  }
                },
              }
            }
          },
          SetOptions(
            merge: true,
          ));
    }
  }

  Future<CollectionReference<Mortality>> addNewMortality(
      Mortality mortality) async {
    final mortalityRef = db.collection(Mortality.mortalityString).withConverter(
          fromFirestore: Mortality.fromFirestore,
          toFirestore: (mortality, options) => mortality.toFirestore(),
        );
    mortalityRef.add(mortality);

    return mortalityRef;
  }

  Future<CollectionReference<Morbidity>> addNewMorbidity(
      Morbidity morbidity) async {
    final morbidityRef = db.collection(Morbidity.morbidityString).withConverter(
          fromFirestore: Morbidity.fromFirestore,
          toFirestore: (morbidity, options) => morbidity.toFirestore(),
        );
    await morbidityRef.add(morbidity);

    return morbidityRef;
  }

  Future<void> deleteRecord(
      {required String collection, required String documentId}) async {
    final docRef = db.collection(collection);
    await docRef.doc(documentId).delete();
  }

  Stream<QuerySnapshot<Natality>> natalitiesStream({
    required DateTime date,
  }) async* {
    final monthRecord = getStartEndOfMonth(date);
    var query = db
        .collection(Natality.natalityString)
        .orderBy('timestamp', descending: true)
        .where('date',
            isGreaterThanOrEqualTo: monthRecord.$1.millisecondsSinceEpoch)
        .where('date',
            isLessThanOrEqualTo: monthRecord.$2.millisecondsSinceEpoch)
        .withConverter(
          fromFirestore: Natality.fromFirestore,
          toFirestore: (natality, options) => natality.toFirestore(),
        );

    yield* query.snapshots();
  }

  Stream<QuerySnapshot<Morbidity>> morbiditiesStream({
    required DateTime date,
  }) async* {
    final monthRecord = getStartEndOfMonth(date);
    var query = db
        .collection(Morbidity.morbidityString)
        .orderBy('timestamp', descending: true)
        .where('date',
            isGreaterThanOrEqualTo: monthRecord.$1.millisecondsSinceEpoch)
        .where('date',
            isLessThanOrEqualTo: monthRecord.$2.millisecondsSinceEpoch)
        .withConverter(
          fromFirestore: Morbidity.fromFirestore,
          toFirestore: (morbidty, options) => morbidty.toFirestore(),
        );

    yield* query.snapshots();
  }

  Stream<QuerySnapshot<Mortality>> mortalitiesStream({
    required DateTime date,
  }) async* {
    final monthRecord = getStartEndOfMonth(date);
    var query = db
        .collection(Mortality.mortalityString)
        .orderBy('timestamp', descending: true)
        .where('date',
            isGreaterThanOrEqualTo: monthRecord.$1.millisecondsSinceEpoch)
        .where('date',
            isLessThanOrEqualTo: monthRecord.$2.millisecondsSinceEpoch)
        .withConverter(
          fromFirestore: Mortality.fromFirestore,
          toFirestore: (mortality, options) => mortality.toFirestore(),
        );

    yield* query.snapshots();
  }
}
