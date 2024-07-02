abstract interface class DataRecord {
  final DateTime date;
  final int diseaseAgeGroup;
  final String gender;

  DataRecord(
      {required this.date,
      required this.gender,
      required this.diseaseAgeGroup});
}
