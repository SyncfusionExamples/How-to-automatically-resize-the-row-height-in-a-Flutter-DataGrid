# How to automatically resize the row height after editing data in a Flutter DataTable.

In this article, we will show you how to automatically resize the row height after editing data in a [Flutter DataTable](https://www.syncfusion.com/flutter-widgets/flutter-datagrid).

Initialize the [SfDataGrid](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/SfDataGrid-class.html) widget with all the required properties. You can achieve this by calling the [DataGridController.refreshRow](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/DataGridController/refreshRow.html) method with the corresponding row index and setting the `recalculateRowHeight` property to true within the [DataGridSource.onCellSubmit](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/DataGridSource/onCellSubmit.html) method.

```dart
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
 
class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource(this.employees, this.dataGridController) {
    dataGridRows = employees
        .map<DataGridRow>((dataGridRow) => dataGridRow.getDataGridRow())
        .toList();
  }
 
  DataGridController dataGridController;
…
 
 @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
…
 
    dataGridController.refreshRow(rowColumnIndex.rowIndex,
        recalculateRowHeight: true);
  }
}
```

You can download this example on [GitHub](https://github.com/SyncfusionExamples/How-to-automatically-resize-the-row-height-in-a-Flutter-DataGrid).