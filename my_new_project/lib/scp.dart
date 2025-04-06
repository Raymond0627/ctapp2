// stock_calculator_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StockCalculatorPage extends StatefulWidget {
  final String plan; // This is the plan data passed from the previous page

  const StockCalculatorPage({super.key, required this.plan});

  @override
  StockCalculatorPageState createState() => StockCalculatorPageState();
}

class StockCalculatorPageState extends State<StockCalculatorPage> {
  TextEditingController stockNameController = TextEditingController();
  TextEditingController stockPriceController = TextEditingController();
  TextEditingController stockQuantityController = TextEditingController();
  double totalStockValue = 0;
  late File stockFile;

  @override
  void initState() {
    super.initState();
    _getFile().then((file) {
      stockFile = file;
    });
  }

  // Get the path to the file in the device's local directory
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/stocks.txt');
    return file;
  }

  // Calculate the total stock value
  void calculateStockValue() {
    final price = double.tryParse(stockPriceController.text);
    final quantity = int.tryParse(stockQuantityController.text);

    if (price != null && quantity != null) {
      setState(() {
        totalStockValue = price * quantity;
      });
    } else {
      // Show an error message if the input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter valid stock price and quantity')),
      );
    }
  }

  // Save the stock data to the file
  Future<void> saveStockData() async {
    final updatedPlan =
        '${widget.plan}, Stock Value: \$${totalStockValue.toStringAsFixed(2)}';

    // Write to the file
    stockFile.writeAsString('$updatedPlan\n', mode: FileMode.append).then((_) {
      // Navigate back after saving
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: stockNameController,
              decoration: const InputDecoration(labelText: 'Stock Name'),
            ),
            TextField(
              controller: stockPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock Price'),
            ),
            TextField(
              controller: stockQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock Quantity'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateStockValue,
              child: const Text('Calculate Stock Value'),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Stock Value: \$${totalStockValue.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveStockData,
              child: const Text('Save and Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
