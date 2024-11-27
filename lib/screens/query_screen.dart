import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class QueryScreen extends StatefulWidget {
  @override
  _QueryScreenState createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final dbHelper = DatabaseHelper.instance;
  String queryDate = '';
  String orderPlan = '';

  void _fetchOrderPlan() async {
    final result = await dbHelper.queryOrderPlan(queryDate);
    setState(() {
      if (result.isNotEmpty) {
        orderPlan = result.first['selected_items'];
      } else {
        orderPlan = 'No order plan found for this date.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Query Order Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Enter Date (YYYY-MM-DD)'),
              onChanged: (value) {
                queryDate = value;
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchOrderPlan,
              child: Text('Query'),
            ),
            SizedBox(height: 20),
            Text(
              orderPlan,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
