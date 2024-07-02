import 'dart:convert';

class HealthStatusSettings {
  final int mortalityTeal;
  final int mortalityYellowGreen;
  final int mortalityOrange;
  final int mortalityRed;
  final int morbidityTeal;
  final int morbidityYellowGreen;
  final int morbidityOrange;
  final int morbidityRed;
  final int natalityTeal;
  final int natalityYellowGreen;
  final int natalityOrange;
  final int natalityRed;

  HealthStatusSettings(
      {required this.mortalityTeal,
      required this.mortalityYellowGreen,
      required this.mortalityOrange,
      required this.mortalityRed,
      required this.morbidityTeal,
      required this.morbidityYellowGreen,
      required this.morbidityOrange,
      required this.morbidityRed,
      required this.natalityTeal,
      required this.natalityYellowGreen,
      required this.natalityOrange,
      required this.natalityRed});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'mortalityTeal': mortalityTeal});
    result.addAll({'mortalityYellowGreen': mortalityYellowGreen});
    result.addAll({'mortalityOrange': mortalityOrange});
    result.addAll({'mortalityRed': mortalityRed});
    result.addAll({'morbidityTeal': morbidityTeal});
    result.addAll({'morbidityYellowGreen': morbidityYellowGreen});
    result.addAll({'morbidityOrange': morbidityOrange});
    result.addAll({'morbidityRed': morbidityRed});
    result.addAll({'natalityTeal': natalityTeal});
    result.addAll({'natalityYellowGreen': natalityYellowGreen});
    result.addAll({'natalityOrange': natalityOrange});
    result.addAll({'natalityRed': natalityRed});

    return result;
  }

  factory HealthStatusSettings.fromMap(Map<String, dynamic> map) {
    return HealthStatusSettings(
      mortalityTeal: map['mortalityTeal']?.toInt() ?? 0,
      mortalityYellowGreen: map['mortalityYellowGreen']?.toInt() ?? 0,
      mortalityOrange: map['mortalityOrange']?.toInt() ?? 0,
      mortalityRed: map['mortalityRed']?.toInt() ?? 0,
      morbidityTeal: map['morbidityTeal']?.toInt() ?? 0,
      morbidityYellowGreen: map['morbidityYellowGreen']?.toInt() ?? 0,
      morbidityOrange: map['morbidityOrange']?.toInt() ?? 0,
      morbidityRed: map['morbidityRed']?.toInt() ?? 0,
      natalityTeal: map['natalityTeal']?.toInt() ?? 0,
      natalityYellowGreen: map['natalityYellowGreen']?.toInt() ?? 0,
      natalityOrange: map['natalityOrange']?.toInt() ?? 0,
      natalityRed: map['natalityRed']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory HealthStatusSettings.fromJson(String source) =>
      HealthStatusSettings.fromMap(json.decode(source));

  HealthStatusSettings.sample()
      : mortalityTeal = 0,
        mortalityYellowGreen = 1,
        mortalityOrange = 3,
        mortalityRed = 4,
        morbidityTeal = 6,
        morbidityYellowGreen = 10,
        morbidityOrange = 14,
        morbidityRed = 18,
        natalityTeal = 1,
        natalityYellowGreen = 3,
        natalityOrange = 5,
        natalityRed = 6;
}
