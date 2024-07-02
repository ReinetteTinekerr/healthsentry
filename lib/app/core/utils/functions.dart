import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:health_sentry/app/core/local_storage/local_data.dart';
import 'package:health_sentry/app/core/utils/date_format.dart';
import 'package:health_sentry/app/features/records/model/data_record.dart';
import 'package:health_sentry/app/features/records/model/morbidity.dart';
import 'package:health_sentry/app/features/records/model/mortality.dart';
import 'package:health_sentry/app/features/records/model/natality.dart';
import 'package:health_sentry/app/features/settings/model/health_status_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

Future<String> getFilePath() async {
  const folderName = 'Monthly_Reports';
  final appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = '${appDocumentsDirectory.path}/$folderName'; // 2
  await Directory(appDocumentsPath).create();
  String filePath = appDocumentsPath; // 3

  return filePath;
}

Future<void> writeSettingsDataToFile(
    HealthStatusSettings data, String filePath) async {
  final String json = jsonEncode(data.toJson());
  await File(filePath).writeAsString(json);
}

Future<HealthStatusSettings> readSettingsData(String filePath) async {
  final file = File(filePath);
  final contents = await file.readAsString();
  final data = await jsonDecode(contents);
  return HealthStatusSettings.fromJson(data);
}

String getRecordName(DataRecord dataRecord) {
  if (dataRecord is Mortality) {
    return Mortality.mortalityString.toUpperCase();
  } else if (dataRecord is Morbidity) {
    return Morbidity.morbidityString.toUpperCase();
  } else if (dataRecord is Natality) {
    return Natality.natalityString.toUpperCase();
  }
  return "";
}

Future<String> exportToExcel(
    {required List<DataRecord> dataRecord, required DateTime date}) async {
  if (dataRecord.isEmpty) return "";
  // init
  final recordName = getRecordName(dataRecord.first);
  final dir = await getFilePath();
  var monthYearString = dateReportFormat.format(date).toUpperCase();
  final monthYearHeadingString = monthYearString.split("_").join(" ");
  final filename = "${monthYearString}_$recordName.xlsx";

  // Heading
  final headingxlsx = [
    (monthYearHeadingString, "A1", "AJ1"),
    ("Municipality of Jones", "A2", "AJ2"),
    ("Province of Isabela", "A3", "AJ3"),
    ("$recordName REPORT", "A4", "AJ4"),
  ];

  // Default styles
  CellStyle defaultCellStyle = CellStyle(
      fontFamily: "Calibri",
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center);

  CellStyle diseaseCellStyleWithMediumBorder = defaultCellStyle.copyWith(
    bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
    topBorderVal: Border(borderStyle: BorderStyle.Medium),
    leftBorderVal: Border(borderStyle: BorderStyle.Medium),
  );

  // create
  var excel = Excel.createExcel();
  Sheet sheetObject = excel[monthYearString];
  excel.delete("Sheet1");

  // set heading column width and input heading data
  const columnCount = 36;
  sheetObject.setColumnWidth(0, 40);
  for (int i = 1; i < columnCount; i++) {
    if (i == columnCount - 1) {
      sheetObject.setColumnWidth(i, 5.5);
      break;
    }
    sheetObject.setColumnWidth(i, 3.3);
  }
  for (final heading in headingxlsx) {
    sheetObject.merge(CellIndex.indexByString(heading.$2),
        CellIndex.indexByString(heading.$3),
        customValue: TextCellValue(heading.$1));

    var cell = sheetObject.cell(CellIndex.indexByString(heading.$2));
    cell.cellStyle = defaultCellStyle.copyWith(
      boldVal: (heading.$2 == "A1" || heading.$2 == "A4"),
    );
  }

  // =====> Mortality and Morbidity has the same excel output
  if (dataRecord is List<Mortality> || dataRecord is List<Morbidity>) {
    // heading cell data
    sheetObject.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("A7"),
        customValue: const TextCellValue("DISEASE"));
    var cellA6 = sheetObject.cell(CellIndex.indexByString("A6"));
    cellA6.cellStyle =
        diseaseCellStyleWithMediumBorder.copyWith(fontSizeVal: 22);

    var startRowMerge = 5;
    var startColMege = 1;
    final ageGroupKeys = LocalData.diseaseAgeGroup.keys.toList();
    ageGroupKeys.addAll(["TOTAL", "GRAND"]);

    for (var i = 0; i < ageGroupKeys.length; i++) {
      if (i == ageGroupKeys.length - 1) {
        var lastCell = sheetObject.cell(CellIndex.indexByColumnRow(
            columnIndex: startColMege, rowIndex: startRowMerge));
        lastCell.value = TextCellValue(ageGroupKeys[i]);
        lastCell.cellStyle = defaultCellStyle.copyWith(
          boldVal: true,
          fontSizeVal: 8,
          topBorderVal: Border(borderStyle: BorderStyle.Medium),
          rightBorderVal: Border(borderStyle: BorderStyle.Medium),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
        );
        break;
      }
      sheetObject.merge(
          CellIndex.indexByColumnRow(
              columnIndex: startColMege, rowIndex: startRowMerge),
          CellIndex.indexByColumnRow(
              columnIndex: startColMege + 1, rowIndex: startRowMerge),
          customValue: TextCellValue(ageGroupKeys[i]));

      var cell = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: startColMege, rowIndex: startRowMerge));
      cell.cellStyle = defaultCellStyle.copyWith(
        boldVal: true,
        fontSizeVal: 8,
        topBorderVal: Border(borderStyle: BorderStyle.Medium),
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal: Border(borderStyle: BorderStyle.Thin),
      );

      var cell2 = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: startColMege + 1, rowIndex: startRowMerge));

      cell2.cellStyle = defaultCellStyle.copyWith(
          boldVal: true,
          fontSizeVal: 8,
          topBorderVal: Border(borderStyle: BorderStyle.Medium),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: i == ageGroupKeys.length - 1
              ? Border(borderStyle: BorderStyle.Medium)
              : null);

      startColMege += 2;
    }

    var a7ToAgHeading2Count = 35;
    var a7row = 6;
    for (var i = 0; i < a7ToAgHeading2Count; i++) {
      if (i == 0) {
        var a7Cell = sheetObject.cell(CellIndex.indexByString('A7'));
        a7Cell.cellStyle = defaultCellStyle.copyWith(
          bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
          leftBorderVal: Border(borderStyle: BorderStyle.Medium),
        );
        continue;
      }
      if (i == a7ToAgHeading2Count - 1) {
        var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: a7row));
        cell.value = const TextCellValue("TOTAL");
        cell.cellStyle = defaultCellStyle.copyWith(
          fontSizeVal: 8,
          boldVal: true,
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: Border(borderStyle: BorderStyle.Medium),
          bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
        );
      }

      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: a7row));
      cell.value = TextCellValue(i % 2 == 0 ? "F" : "M");
      cell.cellStyle = defaultCellStyle.copyWith(
        fontSizeVal: 8,
        boldVal: true,
        leftBorderVal: Border(borderStyle: BorderStyle.Thin),
        bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
      );
    }

    List<String> sortedKeys = [];
    Map<String, List<Mortality>> sortedMortalityDataGroupByDisease = {};
    Map<String, List<Morbidity>> sortedMorbidityDataGroupByDisease = {};

    if (dataRecord is List<Mortality>) {
      final mortalities = dataRecord;
      final dataGroupedByDiseases =
          groupBy(mortalities, (p0) => p0.causeOfDeath);

      sortedKeys = dataGroupedByDiseases.keys.toList()..sort();
      // final sortedDataGroupedByDiseases = <String, List<Mortality>>{};
      for (final key in sortedKeys) {
        sortedMortalityDataGroupByDisease[key] = dataGroupedByDiseases[key]!;
      }
    } else if (dataRecord is List<Morbidity>) {
      final morbidities = dataRecord;
      final dataGroupedByDiseases = groupBy(morbidities, (p0) => p0.disease);

      sortedKeys = dataGroupedByDiseases.keys.toList()..sort();
      // final sortedDataGroupedByDiseases = <String, List<Morbidity>>{};
      for (final key in sortedKeys) {
        sortedMorbidityDataGroupByDisease[key] = dataGroupedByDiseases[key]!;
      }
    }
    final isEmptyMortality = sortedMortalityDataGroupByDisease.isEmpty;
    final sortedDataGroupedByDiseases = isEmptyMortality
        ? sortedMorbidityDataGroupByDisease
        : sortedMortalityDataGroupByDisease;

    const columnCount = 35;
    const a8Row = 7;
    var grandTotalMales = 0;
    var grandTotalFemales = 0;
    for (var i = 0; i < sortedKeys.length; i++) {
      // disease row
      var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: a8Row + i));

      // set disease key
      cell.value = TextCellValue(sortedKeys[i]);
      cell.cellStyle = defaultCellStyle.copyWith(
        horizontalAlignVal: HorizontalAlign.Left,
        fontSizeVal: 8,
        textWrappingVal: TextWrapping.WrapText,
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: Border(borderStyle: BorderStyle.Medium),
        rightBorderVal: Border(borderStyle: BorderStyle.Thin),
      );

      CellValue? currentAgeGroup;
      var totalMales = 0;
      var totalFemales = 0;
      // for each column cell
      for (int j = 0; j < columnCount; j++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(
            columnIndex: j + 1, rowIndex: a8Row + i));

        cell.cellStyle = defaultCellStyle.copyWith(
          fontSizeVal: 8,
          topBorderVal: Border(borderStyle: BorderStyle.Thin),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: Border(borderStyle: BorderStyle.Thin),
        );

        final dataList = sortedDataGroupedByDiseases[sortedKeys[i]]!;

        for (final data in dataList) {
          final gender = j % 2 == 0 ? "M" : "F";

          var cellAgeGroupHeader = sheetObject.cell(
              CellIndex.indexByColumnRow(columnIndex: j + 1, rowIndex: 5));
          currentAgeGroup = cellAgeGroupHeader.value ?? currentAgeGroup;

          // we found a matcha!
          if (data.gender == gender &&
              LocalData.findDiseaseAgeGroupKey(data.diseaseAgeGroup) ==
                  currentAgeGroup.toString()) {
            if (data.gender == "M") {
              totalMales += 1;
              grandTotalMales += 1;
            } else if (data.gender == "F") {
              totalFemales += 1;
              grandTotalFemales += 1;
            }

            var cellInner = sheetObject.cell(CellIndex.indexByColumnRow(
                columnIndex: j + 1, rowIndex: a8Row + i));
            if (cellInner.value != null) {
              cellInner.value =
                  IntCellValue(int.parse(cellInner.value.toString()) + 1);
            } else {
              cellInner.value = const IntCellValue(1);
            }

            cellInner.cellStyle = defaultCellStyle.copyWith(
              fontSizeVal: 8,
              topBorderVal: Border(borderStyle: BorderStyle.Thin),
              bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
              leftBorderVal: Border(borderStyle: BorderStyle.Thin),
              rightBorderVal: Border(borderStyle: BorderStyle.Thin),
            );
          }

          var lastCell = sheetObject.cell(CellIndex.indexByColumnRow(
              columnIndex: j + 1, rowIndex: a8Row + i));
          if (currentAgeGroup.toString().toUpperCase() == "TOTAL") {
            if (gender == "M") {
              lastCell.value = IntCellValue(totalMales);
            } else if (gender == "F") {
              lastCell.value = IntCellValue(totalFemales);
            }

            cell.cellStyle = defaultCellStyle.copyWith(
                fontSizeVal: 8,
                topBorderVal: Border(borderStyle: BorderStyle.Thin),
                bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
                leftBorderVal: Border(borderStyle: BorderStyle.Thin),
                rightBorderVal: Border(borderStyle: BorderStyle.Thin));
          } else if (currentAgeGroup.toString().toUpperCase() == "GRAND") {
            lastCell.value = IntCellValue(totalMales + totalFemales);

            cell.cellStyle = defaultCellStyle.copyWith(
                fontSizeVal: 8,
                topBorderVal: Border(borderStyle: BorderStyle.Thin),
                bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
                leftBorderVal: Border(borderStyle: BorderStyle.Thin),
                rightBorderVal: Border(borderStyle: BorderStyle.Medium));
          }
        }
      }
    }

    // last data cell
    final lastDataCellRow = sortedKeys.length + a8Row;
    for (var i = 0; i < columnCount + 1; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: i, rowIndex: lastDataCellRow));
      if (i == 0) {
        cell.value = const TextCellValue("TOTAL");
      } else if (i == columnCount - 2) {
        cell.value = IntCellValue(grandTotalMales);
      } else if (i == columnCount - 1) {
        cell.value = IntCellValue(grandTotalFemales);
      } else if (i == columnCount) {
        cell.value = IntCellValue(grandTotalMales + grandTotalFemales);
      }

      cell.cellStyle = defaultCellStyle.copyWith(
          fontSizeVal: 8,
          boldVal: true,
          horizontalAlignVal: (i < columnCount - 2)
              ? HorizontalAlign.Left
              : HorizontalAlign.Center,
          topBorderVal: Border(borderStyle: BorderStyle.Thin),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: (i == columnCount)
              ? Border(borderStyle: BorderStyle.Medium)
              : Border(borderStyle: BorderStyle.Thin));
    }

    final footerRowPosition = lastDataCellRow + 2;
    var footerCell = sheetObject.cell(CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: footerRowPosition));
    footerCell.value = const TextCellValue("PREPARED BY:");
    footerCell.cellStyle = defaultCellStyle.copyWith(
        fontSizeVal: 8,
        boldVal: true,
        horizontalAlignVal: HorizontalAlign.Left);

    sheetObject.merge(
        CellIndex.indexByColumnRow(
            columnIndex: 11, rowIndex: footerRowPosition),
        CellIndex.indexByColumnRow(
            columnIndex: 35, rowIndex: footerRowPosition),
        customValue: const TextCellValue("NOTED BY:"));
    var notedByFooterCell = sheetObject.cell(CellIndex.indexByColumnRow(
        columnIndex: 11, rowIndex: footerRowPosition));
    notedByFooterCell.cellStyle = defaultCellStyle.copyWith(
        fontSizeVal: 8,
        boldVal: true,
        horizontalAlignVal: HorizontalAlign.Left);
  } else if (dataRecord is List<Natality>) {
    final natalities = dataRecord;
    sheetObject.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("A7"),
        customValue: const TextCellValue("BARANGAY"));
    var cellA6 = sheetObject.cell(CellIndex.indexByString("A6"));
    cellA6.cellStyle =
        diseaseCellStyleWithMediumBorder.copyWith(fontSizeVal: 22);

    var a6Row = 5;
    var startColMege = 1;
    final ageGroupKeys = LocalData.parentsAgeGroup.keys.toList();
    ageGroupKeys.addAll(["TOTAL", "GRAND"]);

    for (var i = 0; i < ageGroupKeys.length; i++) {
      if (i == ageGroupKeys.length - 1) {
        sheetObject.setColumnWidth(i + 8, 5.5);
        var lastCell = sheetObject.cell(CellIndex.indexByColumnRow(
            columnIndex: startColMege, rowIndex: a6Row));
        lastCell.value = TextCellValue(ageGroupKeys[i]);
        lastCell.cellStyle = defaultCellStyle.copyWith(
          boldVal: true,
          fontSizeVal: 8,
          topBorderVal: Border(borderStyle: BorderStyle.Medium),
          rightBorderVal: Border(borderStyle: BorderStyle.Medium),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
        );
        break;
      }
      sheetObject.merge(
          CellIndex.indexByColumnRow(
              columnIndex: startColMege, rowIndex: a6Row),
          CellIndex.indexByColumnRow(
              columnIndex: startColMege + 1, rowIndex: a6Row),
          customValue: TextCellValue(ageGroupKeys[i]));

      var cell = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: startColMege, rowIndex: a6Row));
      cell.cellStyle = defaultCellStyle.copyWith(
        boldVal: true,
        fontSizeVal: 8,
        topBorderVal: Border(borderStyle: BorderStyle.Medium),
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: Border(borderStyle: BorderStyle.Thin),
        rightBorderVal: Border(borderStyle: BorderStyle.Thin),
      );

      var cell2 = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: startColMege + 1, rowIndex: a6Row));

      cell2.cellStyle = defaultCellStyle.copyWith(
          boldVal: true,
          fontSizeVal: 8,
          topBorderVal: Border(borderStyle: BorderStyle.Medium),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: i == ageGroupKeys.length - 1
              ? Border(borderStyle: BorderStyle.Medium)
              : null);

      startColMege += 2;
    }

    var a7ToAgHeading2Count = 15;
    var a7row = 6;
    for (var i = 0; i < a7ToAgHeading2Count; i++) {
      if (i == 0) {
        var a7Cell = sheetObject.cell(CellIndex.indexByString('A7'));
        a7Cell.cellStyle = defaultCellStyle.copyWith(
          bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
          leftBorderVal: Border(borderStyle: BorderStyle.Medium),
        );
        continue;
      }
      if (i == a7ToAgHeading2Count - 1) {
        var cell = sheetObject.cell(
            CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: a7row));
        cell.value = const TextCellValue("TOTAL");
        cell.cellStyle = defaultCellStyle.copyWith(
          fontSizeVal: 8,
          boldVal: true,
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: Border(borderStyle: BorderStyle.Medium),
          bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
        );
      }

      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: a7row));
      cell.value = TextCellValue(i % 2 == 0 ? "F" : "M");
      cell.cellStyle = defaultCellStyle.copyWith(
        fontSizeVal: 8,
        boldVal: true,
        leftBorderVal: Border(borderStyle: BorderStyle.Thin),
        bottomBorderVal: Border(borderStyle: BorderStyle.Medium),
      );
    }

    // Display the data

    final dataGroupedByBarangay = groupBy(natalities, (p0) => p0.barangay);

    final sortedKeys = dataGroupedByBarangay.keys.toList()..sort();
    final sortedDataGroupByBarangay = <String, List<Natality>>{};
    for (final key in sortedKeys) {
      sortedDataGroupByBarangay[key] = dataGroupedByBarangay[key]!;
    }

    const columnCount = 15;
    const a8Row = 7;
    var grandTotalMales = 0;
    var grandTotalFemales = 0;
    for (int i = 0; i < sortedKeys.length; i++) {
      // disease row
      var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: a8Row + i));

      // set disease key
      cell.value = TextCellValue(sortedKeys[i].toUpperCase());
      cell.cellStyle = defaultCellStyle.copyWith(
        horizontalAlignVal: HorizontalAlign.Left,
        fontSizeVal: 8,
        textWrappingVal: TextWrapping.WrapText,
        topBorderVal: Border(borderStyle: BorderStyle.Thin),
        bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
        leftBorderVal: Border(borderStyle: BorderStyle.Medium),
        rightBorderVal: Border(borderStyle: BorderStyle.Thin),
      );

      CellValue? currentAgeGroup;
      var totalMales = 0;
      var totalFemales = 0;
      for (var j = 0; j < columnCount; j++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(
            columnIndex: j + 1, rowIndex: a8Row + i));

        cell.cellStyle = defaultCellStyle.copyWith(
          fontSizeVal: 8,
          topBorderVal: Border(borderStyle: BorderStyle.Thin),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: Border(borderStyle: BorderStyle.Thin),
        );

        final dataList = sortedDataGroupByBarangay[sortedKeys[i]]!;
        for (final data in dataList) {
          final gender = j % 2 == 0 ? "M" : "F";

          var cellAgeGroupHeader = sheetObject.cell(
              CellIndex.indexByColumnRow(columnIndex: j + 1, rowIndex: 5));
          currentAgeGroup = cellAgeGroupHeader.value ?? currentAgeGroup;

          // we found a matcha!
          if (data.gender == gender &&
              LocalData.findParentsAgeGroupKey(data.motherAgeGroup) ==
                  currentAgeGroup.toString()) {
            if (data.gender == "M") {
              totalMales += 1;
              grandTotalMales += 1;
            } else if (data.gender == "F") {
              totalFemales += 1;
              grandTotalFemales += 1;
            }

            var cellInner = sheetObject.cell(CellIndex.indexByColumnRow(
                columnIndex: j + 1, rowIndex: a8Row + i));
            if (cellInner.value != null) {
              cellInner.value =
                  IntCellValue(int.parse(cellInner.value.toString()) + 1);
            } else {
              cellInner.value = const IntCellValue(1);
            }

            cellInner.cellStyle = defaultCellStyle.copyWith(
              fontSizeVal: 8,
              topBorderVal: Border(borderStyle: BorderStyle.Thin),
              bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
              leftBorderVal: Border(borderStyle: BorderStyle.Thin),
              rightBorderVal: Border(borderStyle: BorderStyle.Thin),
            );
          }
          var lastCell = sheetObject.cell(CellIndex.indexByColumnRow(
              columnIndex: j + 1, rowIndex: a8Row + i));
          if (currentAgeGroup.toString().toUpperCase() == "TOTAL") {
            if (gender == "M") {
              lastCell.value = IntCellValue(totalMales);
            } else if (gender == "F") {
              lastCell.value = IntCellValue(totalFemales);
            }

            cell.cellStyle = defaultCellStyle.copyWith(
                fontSizeVal: 8,
                topBorderVal: Border(borderStyle: BorderStyle.Thin),
                bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
                leftBorderVal: Border(borderStyle: BorderStyle.Thin),
                rightBorderVal: Border(borderStyle: BorderStyle.Thin));
          } else if (currentAgeGroup.toString().toUpperCase() == "GRAND") {
            lastCell.value = IntCellValue(totalMales + totalFemales);

            cell.cellStyle = defaultCellStyle.copyWith(
                fontSizeVal: 8,
                topBorderVal: Border(borderStyle: BorderStyle.Thin),
                bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
                leftBorderVal: Border(borderStyle: BorderStyle.Thin),
                rightBorderVal: Border(borderStyle: BorderStyle.Medium));
          }
        }
      }
    }

    final lastDataCellRow = sortedKeys.length + a8Row;
    for (var i = 0; i < columnCount + 1; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(
          columnIndex: i, rowIndex: lastDataCellRow));
      if (i == 0) {
        cell.value = const TextCellValue("TOTAL");
      } else if (i == columnCount - 2) {
        cell.value = IntCellValue(grandTotalMales);
      } else if (i == columnCount - 1) {
        cell.value = IntCellValue(grandTotalFemales);
      } else if (i == columnCount) {
        cell.value = IntCellValue(grandTotalMales + grandTotalFemales);
      }

      cell.cellStyle = defaultCellStyle.copyWith(
          fontSizeVal: 8,
          boldVal: true,
          horizontalAlignVal: (i < columnCount - 2)
              ? HorizontalAlign.Left
              : HorizontalAlign.Center,
          topBorderVal: Border(borderStyle: BorderStyle.Thin),
          bottomBorderVal: Border(borderStyle: BorderStyle.Thin),
          leftBorderVal: Border(borderStyle: BorderStyle.Thin),
          rightBorderVal: (i == columnCount)
              ? Border(borderStyle: BorderStyle.Medium)
              : Border(borderStyle: BorderStyle.Thin));
    }

    final footerRowPosition = lastDataCellRow + 2;
    var footerCell = sheetObject.cell(CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: footerRowPosition));
    footerCell.value = const TextCellValue("PREPARED BY:");
    footerCell.cellStyle = defaultCellStyle.copyWith(
        fontSizeVal: 8,
        boldVal: true,
        horizontalAlignVal: HorizontalAlign.Left);

    sheetObject.merge(
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: footerRowPosition),
        CellIndex.indexByColumnRow(
            columnIndex: 15, rowIndex: footerRowPosition),
        customValue: const TextCellValue("NOTED BY:"));
    var notedByFooterCell = sheetObject.cell(CellIndex.indexByColumnRow(
        columnIndex: 7, rowIndex: footerRowPosition));
    notedByFooterCell.cellStyle = defaultCellStyle.copyWith(
        fontSizeVal: 8,
        boldVal: true,
        horizontalAlignVal: HorizontalAlign.Left);

    var r6Cell = sheetObject.cell(CellIndex.indexByString("R6"));
    var r7Cell = sheetObject.cell(CellIndex.indexByString("R7"));
    r6Cell.value = const TextCellValue("Parent's age group");
    r7Cell.value = const TextCellValue("Child gender");
  }
  //save
  var fileBytes = excel.save();
  File("$dir/$filename")
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);

  return "$dir/$filename";
}

Future<void> fileSavedInfoBar(
    fluent.BuildContext context, String filename) async {
  await fluent.displayInfoBar(context, alignment: fluent.Alignment.topCenter,
      builder: (context, close) {
    return fluent.InfoBar(
      title: const fluent.Text('Saved'),
      content: fluent.Text('File saved at $filename'),
      action: fluent.IconButton(
        icon: const fluent.Icon(fluent.FluentIcons.clear),
        onPressed: close,
      ),
      severity: fluent.InfoBarSeverity.success,
    );
  });
}
