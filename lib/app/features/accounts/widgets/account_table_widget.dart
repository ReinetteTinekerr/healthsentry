import 'package:data_table_2/data_table_2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:health_sentry/app/core/utils/date_format.dart';
import 'package:health_sentry/app/features/accounts/model/user.dart';

class AccountPaginatedDataTableWidget extends StatelessWidget {
  const AccountPaginatedDataTableWidget({
    super.key,
    required this.data,
  });

  final List<User> data;

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
            label: Text('Username'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Barangay'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Email'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Role'),
            size: ColumnSize.S,
          ),
        ],
        source: AccountDataSource(data: data),
      ),
    );
  }
}

class AccountDataSource extends material.DataTableSource {
  final List<User> data;

  AccountDataSource({required this.data});

  @override
  material.DataRow? getRow(int index) {
    if (index > data.length || index < 0) return null;
    final user = data[index];
    return DataRow2(onTap: () {}, cells: [
      material.DataCell(Text(
        timestampFormat.format(user.timestamp),
        style: const TextStyle(fontSize: 12),
      )),
      material.DataCell(Text(user.username)),
      material.DataCell(Text(
        user.barangay.toUpperCase(),
      )),
      material.DataCell(Text(user.email)),
      material.DataCell(Text(User.getRoleString(user.role).toUpperCase())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
