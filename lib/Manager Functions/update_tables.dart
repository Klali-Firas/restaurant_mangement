import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart'
    as realtimedatabase;

class UpdateTables extends StatefulWidget {
  const UpdateTables({super.key});
  @override
  State<UpdateTables> createState() => _UpdateTablesState();
}

class _UpdateTablesState extends State<UpdateTables> {
  late List<String> tableIdentifiers = [];
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Tables"),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: textController,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: addItem,
                    child: const Text("Add New Table!"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: realtimedatabase.getData("Tables").onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLoadingIndicator(); // Display a loading indicator while data is loading.
                  }
                  final dynamic snapshotValue = snapshot.data?.snapshot.value;
                  if (snapshotValue == null) {
                    return _buildNoDataAvailable(); // Display a message when there's no table data.
                  }
                  _updateTableIdentifiers(
                      snapshotValue); // Update the list of table identifiers.
                  return _buildTableList();
                },
              ),
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Text("Swipe "),
              Text(
                "left",
                style:
                    TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
              Text(" to delete a table!")
            ]),
            const SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(16),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildNoDataAvailable() {
    return const Center(
        child: Text(
      "No tables available!\nTry adding some.",
      textAlign: TextAlign.center,
    ));
  }

  void addItem() {
    final inputText = textController.text.trim();
    if (inputText.isNotEmpty) {
      setState(() {
        tableIdentifiers.add(inputText); // Add a new table to the list.
        useAddData(inputText); // Add table data to the database.
        textController.clear(); // Clear the input field.
      });
    }
  }

  void useAddData(String tableName) {
    realtimedatabase.addData("Tables/$tableName", {
      "Created Time": DateTime.now().toString(),
      "empty": true,
      "paid": null,
      "paycheck": null,
    }); // Add table data to the database.
  }

  void _updateTableIdentifiers(dynamic snapshotValue) {
    if (snapshotValue is Map) {
      tableIdentifiers = snapshotValue.keys
          .cast<String>()
          .toList(); // Update the list of table identifiers.
    } else {
      tableIdentifiers = [];
    }
  }

  Widget _buildTableList() {
    return ListView.builder(
      itemCount: tableIdentifiers.length,
      itemBuilder: (context, index) {
        final tableName = tableIdentifiers[index];
        return Dismissible(
          key: UniqueKey(),
          confirmDismiss: (direction) async {
            return await _confirmDeletion(context, tableName);
          },
          onDismissed: (direction) {
            realtimedatabase.removeData(
                "Tables/$tableName"); // Remove table data from the database.
          },
          direction: DismissDirection.endToStart,
          background: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              height: 30,
              alignment: Alignment.centerRight,
              color: const Color.fromARGB(255, 236, 236, 236),
              child: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.delete_outline_rounded, // Delete icon for swipe action.
                  color: Colors.teal,
                  size: 25,
                ),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Material(
              color: Colors.white,
              elevation: 8,
              shadowColor: Colors.black,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(6),
                child: ListTile(
                  tileColor: Colors.white,
                  title: Text(
                    tableName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDeletion(BuildContext context, String tableName) async {
    // Check if the table is empty before showing the confirmation dialog
    bool isTableEmpty = await realtimedatabase
        .getData("Tables/$tableName/empty")
        .once()
        .then((value) {
      return value.snapshot.value == true;
    });

    if (!isTableEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Table is not empty!"),
            content: const Text("Table is not empty and cannot be deleted."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return false; // Prevent deletion since the table is not empty
    }

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: const Text(
              "Confirm action?"), // Confirmation dialog for deletion.
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
