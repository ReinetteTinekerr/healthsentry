import 'package:data_table_2/data_table_2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/local_storage/local_data.dart';
import 'package:health_sentry/app/core/utils/date_format.dart';
import 'package:health_sentry/app/core/utils/functions.dart';
import 'package:health_sentry/app/core/utils/validator.dart';
import 'package:health_sentry/app/features/accounts/model/user.dart';
import 'package:health_sentry/app/features/accounts/providers/accounts_provider.dart';
import 'package:health_sentry/app/features/records/model/morbidity.dart';
import 'package:health_sentry/app/features/records/providers/morbidities_provider.dart';
import 'package:health_sentry/app/features/records/providers/mortalities_provider.dart';
import 'package:health_sentry/app/features/records/providers/records_provider.dart';
import 'package:health_sentry/app/features/records/repository/records_repository.dart';
import 'package:health_sentry/app/features/records/widgets/commandbar_widget.dart';
import 'package:flutter/material.dart' as material;

class MorbidityWidget extends ConsumerStatefulWidget {
  const MorbidityWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MorbidityWidgetState();
}

class _MorbidityWidgetState extends ConsumerState<MorbidityWidget> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final morbiditiesStream = ref.watch(morbiditiesStreamProvider);
    final currentUserFuture = ref.watch(currentUserFutureProvider);

    return ScaffoldPage(
      padding: const EdgeInsets.symmetric(vertical: 8),
      header: PageHeader(
        commandBar: CommandBarWidget(
          newContentDialog: () {
            currentUserFuture.maybeWhen(
              data: (data) {
                if (data == null) return;
                newMorbidityContentDialog(
                  context,
                  userBarangay: data.barangay,
                  callback: (morbidity) {
                    morbidity = morbidity.copyWith(
                        userId: data.userId, submittedBy: data.username);
                    ref
                        .read(recordsProvider)
                        .addNewMorbidity(morbidity)
                        .then((value) {});
                    ref
                        .read(recordsProvider)
                        .updateSummary(dataRecord: morbidity)
                        .then(
                          (value) {},
                        );
                  },
                );
              },
              orElse: () {},
            );
          },
          exportData: () async {
            morbiditiesStream.maybeWhen(
              data: (data) {
                final natalities = data.docs.map((e) => e.data()).toList();

                final selectedDate = ref.read(currentDateMortalitiesProvider);
                exportToExcel(dataRecord: natalities, date: selectedDate).then(
                  (value) async {
                    if (value.isEmpty) return;
                    await fileSavedInfoBar(context, value);
                  },
                );
              },
              orElse: () {},
            );
          },
        ),
      ),
      content: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Wrap(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 250,
                  child: DatePicker(
                    selected: selectedDate,
                    onChanged: (newDate) {
                      selectedDate = newDate;
                      ref.read(currentDateMorbiditiesProvider.notifier).state =
                          newDate;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 550,
                width: double.infinity,
                child: morbiditiesStream.when(
                  data: (data) {
                    final morbidities = data.docs.map((e) {
                      return (e.id, e.data());
                    }).toList();
                    return PaginatedDataTableWidget(
                      data: morbidities,
                      callback: (morbidity) async {
                        currentUserFuture.maybeWhen(
                          data: (data) {
                            showMorbidityContentDialog(
                              context,
                              morbidityWithDocId: morbidity,
                              user: data,
                              deleteCallback: (documentId) {
                                ref.read(recordsProvider).deleteRecord(
                                    collection: Morbidity.morbidityString,
                                    documentId: documentId);

                                ref
                                    .read(recordsProvider)
                                    .updateSummary(
                                        dataRecord: morbidity.$2,
                                        type: SummaryType.decrement)
                                    .then(
                                      (value) {},
                                    );
                              },
                            );
                          },
                          orElse: () {},
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return Stack(
                      children: [
                        PaginatedDataTableWidget(
                          data: const [],
                          callback: (morbidity) {},
                        ),
                        Center(
                          child: InfoBar(
                            title: const Text('Something went wrong :/'),
                            content: const Text(''),
                            action: IconButton(
                              icon: const Icon(FluentIcons.clear),
                              onPressed: () {
                                ref
                                    .read(
                                        currentDateMorbiditiesProvider.notifier)
                                    .state = DateTime.now();
                              },
                            ),
                            severity: InfoBarSeverity.error,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.1,
                      child: ProgressBar(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void newMorbidityContentDialog(BuildContext context,
      {required String userBarangay,
      required void Function(Morbidity morbidity) callback}) async {
    var selectedDate = DateTime.now();
    var selectedAgeGroup = LocalData.diseaseAgeGroup.entries.first.value;
    var selectedGender = LocalData.genders.values.first;
    var selectedBarangay = userBarangay;
    LocalData.diseases.sort();
    var selectedDisease = LocalData.diseases.first;
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('New Morbidity'),
        content: StatefulBuilder(
          builder: (context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DatePicker(
                      header: 'Select date',
                      selected: selectedDate,
                      onChanged: (date) {
                        setState(
                          () => selectedDate = date,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: 'Disease',
                      child: AutoSuggestBox<String>(
                        placeholder: selectedDisease.toUpperCase(),
                        onChanged: (text, reason) {
                          setState(
                            () => selectedDisease = text.toUpperCase(),
                          );
                        },
                        onSelected: (disease) =>
                            setState(() => selectedDisease = disease.value!),
                        items: LocalData.diseases.map(
                          (barangay) {
                            return AutoSuggestBoxItem<String>(
                              value: barangay,
                              label: barangay.toUpperCase(),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: "Age",
                      child: ComboBox(
                        value: selectedAgeGroup,
                        items: LocalData.diseaseAgeGroup.entries.map(
                          (e) {
                            return ComboBoxItem(
                              value: e.value,
                              child: Text(e.key.toUpperCase()),
                            );
                          },
                        ).toList(),
                        onChanged: (value) => setState(
                          () => selectedAgeGroup = value!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: 'Gender',
                      child: ComboBox(
                        value: selectedGender,
                        items: LocalData.genders.entries.map(
                          (e) {
                            return ComboBoxItem(
                              value: e.value.toUpperCase(),
                              child: Text(e.key.toUpperCase()),
                            );
                          },
                        ).toList(),
                        onChanged: (value) => setState(
                          () => selectedGender = value!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoLabel(
                      label: 'Barangay',
                      child: AutoSuggestBox<String>(
                        placeholder: selectedBarangay.toUpperCase(),
                        onSelected: (barangay) =>
                            setState(() => selectedBarangay = barangay.value!),
                        items: LocalData.barangays.map(
                          (barangay) {
                            return AutoSuggestBoxItem<String>(
                              value: barangay,
                              label: barangay.toUpperCase(),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, 'cancel');
              // Delete file here
            },
          ),
          FilledButton(
            child: const Text('Submit'),
            onPressed: () {
              callback(Morbidity(
                  userId: '--',
                  timestamp: DateTime.now(),
                  date: selectedDate,
                  gender: selectedGender,
                  barangay: selectedBarangay,
                  diseaseAgeGroup: selectedAgeGroup,
                  disease: selectedDisease,
                  submittedBy: '--'));
              Navigator.pop(context, 'done');
            },
          ),
        ],
      ),
    );
    setState(() {});
  }

  void showMorbidityContentDialog(BuildContext context,
      {required (String, Morbidity) morbidityWithDocId,
      required User? user,
      required void Function(String documentId) deleteCallback}) async {
    final docId = morbidityWithDocId.$1;
    final morbidity = morbidityWithDocId.$2;
    final userId = user!.userId;
    final hasPermission = hasDeletePermission(
        docUserId: morbidity.userId, currentUserId: userId, role: user.role);

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Morbidity'),
            Text(
              timestampFormat.format(morbidity.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "Date",
                child: TextBox(
                  placeholder: dateFormat.format(morbidity.date),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Disease",
                child: TextBox(
                  minLines: 1,
                  maxLines: 3,
                  placeholder: morbidity.disease,
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Age",
                child: TextBox(
                  placeholder: LocalData.findDiseaseAgeGroupKey(
                      morbidity.diseaseAgeGroup),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Gender",
                child: TextBox(
                  placeholder: LocalData.findGenderKey(morbidity.gender),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Barangay",
                child: TextBox(
                  placeholder: morbidity.barangay.toUpperCase(),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
              InfoLabel(
                label: "Submitted by",
                child: TextBox(
                  placeholder: morbidity.submittedBy.toUpperCase(),
                  placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  enabled: false,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Button(
            onPressed: !hasPermission
                ? null
                : () {
                    deleteCallback(docId);
                    Navigator.pop(context, 'delete');
                    // Delete file here
                  },
            child: Text('Delete',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context, 'close');
            },
          ),
        ],
      ),
    );
    setState(() {});
  }
}

class PaginatedDataTableWidget extends StatelessWidget {
  const PaginatedDataTableWidget(
      {super.key, required this.data, required this.callback});

  final List<(String, Morbidity)> data;
  final void Function((String, Morbidity) morbidity) callback;

  @override
  Widget build(BuildContext context) {
    return material.Material(
      child: PaginatedDataTable2(
        headingRowColor: WidgetStateProperty.all(Colors.black),
        headingTextStyle: const TextStyle(color: Colors.white),
        columns: const [
          DataColumn2(
            label: Text('Timestamp'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Date'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Disease'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Age'),
          ),
          DataColumn2(
            label: Text('Gender'),
          ),
          DataColumn2(
            label: Text('Barangay'),
          ),
          DataColumn2(
            label: Text('Submitted by'),
          ),
        ],
        source: MorbidityDataSource(data: data, callback: callback),
      ),
    );
  }
}

class MorbidityDataSource extends material.DataTableSource {
  final List<(String, Morbidity)> data;
  final void Function((String, Morbidity) morbidity) callback;

  MorbidityDataSource({required this.data, required this.callback});

  @override
  material.DataRow? getRow(int index) {
    if (index > data.length || index < 0) return null;

    final morbidityWithDocId = data[index];
    final morbidity = morbidityWithDocId.$2;
    return DataRow2(
        onTap: () {
          callback(morbidityWithDocId);
        },
        cells: [
          material.DataCell(Text(
            timestampFormat.format(morbidity.timestamp),
            style: const TextStyle(fontSize: 12),
          )),
          material.DataCell(Text(dateFormat.format(morbidity.date))),
          material.DataCell(Text(
            morbidity.disease,
            style: const TextStyle(fontSize: 11, overflow: TextOverflow.fade),
          )),
          material.DataCell(Text(
              LocalData.findDiseaseAgeGroupKey(morbidity.diseaseAgeGroup))),
          material.DataCell(Text(morbidity.gender)),
          material.DataCell(Text(morbidity.barangay.toUpperCase())),
          material.DataCell(Text(morbidity.submittedBy.toUpperCase())),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
