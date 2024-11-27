import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'query_screen.dart';
import 'crud_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;

  double targetCost = 0.0;
  String selectedDate = _formatDate(DateTime.now());
  List<Map<String, dynamic>> foodItems = [];
  List<int> selectedFoodItems = [];

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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

  void _saveOrderPlan() async {
    double totalCost = selectedFoodItems.fold(0, (sum, index) => sum + foodItems[index]['cost']);

    if (totalCost > targetCost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Total cost exceeds target!')));
      return;
    }

    String selectedItemsString = selectedFoodItems.map((index) => foodItems[index]['name']).join(', ');

    await dbHelper.insertOrderPlan({
      'date': selectedDate,
      'target_cost': targetCost,
      'selected_items': selectedItemsString,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order plan saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Ordering App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Target Cost per Day'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                targetCost = double.tryParse(value) ?? 0.0;
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Date: $selectedDate'),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = _formatDate(date);
                      });
                    }
                  },
                  child: Text('Select Date'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text('${foodItems[index]['name']} (\$${foodItems[index]['cost']})'),
                    value: selectedFoodItems.contains(index),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedFoodItems.add(index);
                        } else {
                          selectedFoodItems.remove(index);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveOrderPlan,
              child: Text('Save Order Plan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QueryScreen()),
                );
              },
              child: Text('Query Order Plan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrudScreen()),
                );
              },
              child: Text('Manage Food Items'),
            ),
          ],
        ),
      ),
    );
  }
}
