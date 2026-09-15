import 'package:flutter/material.dart';
import 'package:larnity/src/core/ui/widgets/app_table.dart';

// Example usage widget
class TableExample extends StatelessWidget {
  const TableExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final List<Map<String, dynamic>> sampleData = [
      {
        'promoCode': '9Z4377BB',
        'planType': 'MONTHLY',
        'discount': 10,
        'usage': '0/5',
        'status': true,
      },
      {
        'promoCode': 'ABC123XY',
        'planType': 'YEARLY',
        'discount': 25,
        'usage': '3/10',
        'status': false,
      },
      {
        'promoCode': 'SAVE50FF',
        'planType': 'WEEKLY',
        'discount': 50,
        'usage': '1/3',
        'status': true,
      },
      {
        'promoCode': 'NEWUSER2024',
        'planType': 'MONTHLY',
        'discount': 15,
        'usage': '7/20',
        'status': false,
      },
      {
        'promoCode': '9Z4377BB',
        'planType': 'MONTHLY',
        'discount': 10,
        'usage': '0/5',
        'status': true,
      },
      {
        'promoCode': 'ABC123XY',
        'planType': 'YEARLY',
        'discount': 25,
        'usage': '3/10',
        'status': false,
      },
      {
        'promoCode': 'SAVE50FF',
        'planType': 'WEEKLY',
        'discount': 50,
        'usage': '1/3',
        'status': true,
      },
      {
        'promoCode': 'NEWUSER2024',
        'planType': 'MONTHLY',
        'discount': 15,
        'usage': '7/20',
        'status': false,
      },
      {
        'promoCode': '9Z4377BB',
        'planType': 'MONTHLY',
        'discount': 10,
        'usage': '0/5',
        'status': true,
      },
      {
        'promoCode': 'ABC123XY',
        'planType': 'YEARLY',
        'discount': 25,
        'usage': '3/10',
        'status': false,
      },
      {
        'promoCode': 'SAVE50FF',
        'planType': 'WEEKLY',
        'discount': 50,
        'usage': '1/3',
        'status': true,
      },
      {
        'promoCode': 'NEWUSER2024',
        'planType': 'MONTHLY',
        'discount': 15,
        'usage': '7/20',
        'status': false,
      },
      {
        'promoCode': '9Z4377BB',
        'planType': 'MONTHLY',
        'discount': 10,
        'usage': '0/5',
        'status': true,
      },
      {
        'promoCode': 'ABC123XY',
        'planType': 'YEARLY',
        'discount': 25,
        'usage': '3/10',
        'status': false,
      },
      {
        'promoCode': 'SAVE50FF',
        'planType': 'WEEKLY',
        'discount': 50,
        'usage': '1/3',
        'status': true,
      },
      {
        'promoCode': 'NEWUSER2024',
        'planType': 'MONTHLY',
        'discount': 15,
        'usage': '7/20',
        'status': false,
      },
    ];

    // Define table columns
    final List<TableColumn> columns = [
      TableColumn(
        title: 'Promo Code',
        width: 140,
        cellBuilder: (index) => Row(
          children: [
            Expanded(
              child: Text(
                sampleData[index]['promoCode'],
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.copy, size: 16, color: Colors.grey),
          ],
        ),
      ),
      TableColumn(
        title: 'Plan Type',
        width: 120,
        cellBuilder: (index) => Text(
          sampleData[index]['planType'],
          style: const TextStyle(color: Colors.grey),
        ),
      ),
      TableColumn(
        title: 'Discount',
        width: 100,
        cellBuilder: (index) => Text(
          '${sampleData[index]['discount']}%',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      TableColumn(
        title: 'Usage',
        width: 80,
        cellBuilder: (index) => Text(
          sampleData[index]['usage'],
          style: const TextStyle(color: Colors.grey),
        ),
      ),
      TableColumn(
        title: 'Status',
        width: 80,
        cellBuilder: (index) => Switch(
          value: sampleData[index]['status'],
          onChanged: (value) {
            // Handle switch toggle
            debugPrint('Toggle status for row $index');
          },
          activeThumbColor: Colors.green,
        ),
      ),
      TableColumn(
        title: 'Actions',
        width: 100,
        cellBuilder: (index) => ElevatedButton(
          onPressed: () {
            debugPrint('Delete row $index');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
          ),
          child: const Text(
            'Delete',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Reusable Table Widget'),
        backgroundColor: const Color(0xFF2D2D2D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Scrollable Data Table Example',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              AppTable(
                columns: columns,
                rowCount: sampleData.length,
                headerColor: const Color(0xFF2D2D2D),
                borderColor: const Color(0xFF444444),
                rowHeight: 70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrollable Table Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: TableExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}
