import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MaterialApp(home: SfDataGridDemo()));
}

class SfDataGridDemo extends StatefulWidget {
  const SfDataGridDemo({super.key});

  @override
  SfDataGridDemoState createState() => SfDataGridDemoState();
}

class SfDataGridDemoState extends State<SfDataGridDemo> {
  List<Employee> _employees = <Employee>[];
  late EmployeeDataSource _employeeDataSource;
  DataGridController dataGridController = DataGridController();

  @override
  void initState() {
    super.initState();
    _employees = getEmployeeData();
    _employeeDataSource = EmployeeDataSource(_employees, dataGridController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syncfusion Flutter DataGrid')),
      body: SfDataGrid(
        controller: dataGridController,
        source: _employeeDataSource,
        columns: getColumns,
        allowEditing: true,
        navigationMode: GridNavigationMode.cell,
        selectionMode: SelectionMode.single,
        onQueryRowHeight: (details) {
          return details.getIntrinsicRowHeight(details.rowIndex);
        },
      ),
    );
  }

  List<GridColumn> get getColumns {
    return <GridColumn>[
      GridColumn(
          columnName: 'ID',
          label: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerRight,
              child: const Text('ID'))),
      GridColumn(
          columnName: 'Name',
          label: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: const Text('Name'))),
      GridColumn(
          columnName: 'Designation',
          width: 150,
          label: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: const Text('Designation'))),
      GridColumn(
          columnName: 'Salary',
          label: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerRight,
              child: const Text('Salary'))),
    ];
  }

  List<Employee> getEmployeeData() {
    return [
      Employee(10001, 'Lara', 'Project Lead', 75000),
      Employee(10002, 'James', 'Developer', 43000),
      Employee(10003, 'Kathryn', 'Project Lead', 73500),
      Employee(10004, 'Michael', 'Manager', 90000),
      Employee(10005, 'Martin', 'Developer', 42000),
    ];
  }
}

class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource(this.employees, this.dataGridController) {
    dataGridRows = employees
        .map<DataGridRow>((dataGridRow) => dataGridRow.getDataGridRow())
        .toList();
  }

  List<Employee> employees = [];

  List<DataGridRow> dataGridRows = [];

  DataGridController dataGridController;

  /// Helps to hold the new value of all editable widget.
  /// Based on the new value we will commit the new value into the corresponding
  /// [DataGridCell] on [onSubmitCell] method.
  dynamic newCellValue;

  /// Help to control the editable text in [TextField] widget.
  TextEditingController editingController = TextEditingController();

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: (dataGridCell.columnName == 'ID' ||
                  dataGridCell.columnName == 'Salary')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
          ));
    }).toList());
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value ??
        '';

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    if (column.columnName == 'ID') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'ID', value: newCellValue);
      employees[dataRowIndex].id = newCellValue as int;
    } else if (column.columnName == 'Name') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'Name', value: newCellValue);
      employees[dataRowIndex].name = newCellValue.toString();
    } else if (column.columnName == 'Designation') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'Designation', value: newCellValue);
      employees[dataRowIndex].designation = newCellValue.toString();
    } else {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'Salary', value: newCellValue);
      employees[dataRowIndex].salary = newCellValue as int;
    }
    dataGridController.refreshRow(rowColumnIndex.rowIndex,
        recalculateRowHeight: true);
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value
            ?.toString() ??
        '';

    // The new cell value must be reset.
    // To avoid committing the [DataGridCell] value that was previously edited
    // into the current non-modified [DataGridCell].
    newCellValue = null;

    final bool isNumericType =
        column.columnName == 'ID' || column.columnName == 'Salary';

    // Holds regular expression pattern based on the column type.
    final RegExp regExp = _getRegExp(isNumericType, column.columnName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        style: const TextStyle(fontSize: 14),
        controller: editingController..text = displayText,
        textAlign: isNumericType ? TextAlign.right : TextAlign.left,
        autofocus: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(regExp)
        ],
        keyboardType: isNumericType ? TextInputType.number : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType) {
              newCellValue = int.parse(value);
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          /// Call [CellSubmit] callback to fire the canSubmitCell and
          /// onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  RegExp _getRegExp(bool isNumericKeyBoard, String columnName) {
    return isNumericKeyBoard ? RegExp('[0-9]') : RegExp('[a-zA-Z ]');
  }
}

class Employee {
  Employee(this.id, this.name, this.designation, this.salary);

  int? id;
  String? name;
  String? designation;
  int? salary;

  DataGridRow getDataGridRow() {
    return DataGridRow(cells: <DataGridCell>[
      DataGridCell<int>(columnName: 'ID', value: id),
      DataGridCell<String>(columnName: 'Name', value: name),
      DataGridCell<String>(columnName: 'Designation', value: designation),
      DataGridCell<int>(columnName: 'Salary', value: salary),
    ]);
  }
}
