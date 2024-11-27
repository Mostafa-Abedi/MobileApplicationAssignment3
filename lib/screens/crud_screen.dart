import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> foodItems = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  int? editingId;

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  void _fetchFoodItems() async {
    final items = await dbHelper.queryAllFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  void _addOrUpdateFoodItem() async {
    final name = nameController.text;
    final cost = double.tryParse(costController.text) ?? 0.0;

    if (name.isEmpty || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid input!')));
      return;
    }

    if (editingId == null) {
      await dbHelper.insertFoodItem({'name': name, 'cost': cost});
    } else {
      await dbHelper.updateFoodItem({'id': editingId, 'name': name, 'cost': cost});
      editingId = null;
    }

    nameController.clear();
    costController.clear();
    _fetchFoodItems();
  }

  void _deleteFoodItem(int id) async {
    await dbHelper.deleteFoodItem(id);
    _fetchFoodItems();
  }

  void _editFoodItem(Map<String, dynamic> item) {
    nameController.text = item['name'];
    costController.text = item['cost'].toString();
    setState(() {
      editingId = item['id'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Food Items')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Food Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: costController,
              decoration: InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrUpdateFoodItem,
              child: Text(editingId == null ? 'Add Food Item' : 'Update Food Item'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  final item = foodItems[index];
                  return ListTile(
                    title: Text('${item['name']} (\$${item['cost']})'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editFoodItem(item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteFoodItem(item['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
