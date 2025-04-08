import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SalesPage extends StatefulWidget {
  final List<Map<String, dynamic>> stockData;
  final String planName;

  const SalesPage({
    super.key,
    required this.stockData,
    required this.planName,
  });

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Map<String, dynamic>> _initialStock;
  final List<Map<String, dynamic>> _salesRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialStock = List<Map<String, dynamic>>.from(widget.stockData);
    _loadSalesData();
  }

  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/sales_data_${widget.planName}.json';
  }

  Future<void> _loadSalesData() async {
    final filePath = await _getLocalFilePath();
    final file = File(filePath);
    if (await file.exists()) {
      final contents = await file.readAsString();
      final Map<String, dynamic> planData = jsonDecode(contents);
      setState(() {
        _initialStock = List<Map<String, dynamic>>.from(planData['stockData']);
        _salesRecords
            .addAll(List<Map<String, dynamic>>.from(planData['salesRecords']));
      });
    }
  }

  Future<void> _saveSalesData() async {
    final filePath = await _getLocalFilePath();
    final file = File(filePath);

    // Save the updated stock and sales data into a map
    final planData = {
      'planName': widget.planName,
      'stockData': _initialStock,
      'salesRecords': _salesRecords,
    };

    // Write the data to the file
    await file.writeAsString(jsonEncode(planData));
  }

  double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + item['price'] * item['quantity']);
  }

  List<Map<String, dynamic>> _getRemainingStock() {
    List<Map<String, dynamic>> remaining = List.from(_initialStock);
    for (var sale in _salesRecords) {
      final index =
          remaining.indexWhere((item) => item['name'] == sale['name']);
      if (index != -1) {
        remaining[index]['quantity'] -= sale['quantity'];
      }
    }
    return remaining;
  }

  void _recordSale(Map<String, dynamic> item, int quantitySold) async {
    setState(() {
      _salesRecords.add({
        'name': item['name'],
        'quantity': quantitySold,
        'price': item['price'],
      });
    });

    // Save the updated sales data
    await _saveSalesData();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> remainingStock = _getRemainingStock();
    double totalSaleAmount = _calculateTotal(_salesRecords);
    double totalRemainingValue = _calculateTotal(remainingStock);
    double totalInitialValue = _calculateTotal(_initialStock);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales - ${widget.planName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Initial Stock'),
            Tab(text: 'Remaining Stock'),
            Tab(text: 'Sales Record'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockList(_initialStock, totalInitialValue),
          _buildStockList(remainingStock, totalRemainingValue),
          _buildSalesList(totalSaleAmount),
        ],
      ),
    );
  }

  Widget _buildStockList(List<Map<String, dynamic>> items, double total) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name']),
                subtitle:
                    Text('Qty: ${item['quantity']} | Unit: ${item['price']}'),
                trailing: Text(
                    'Total: ${(item['quantity'] * item['price']).toStringAsFixed(2)}'),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Total Value: ${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesList(double totalSales) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _initialStock.length,
            itemBuilder: (context, index) {
              final item = _initialStock[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text('Available: ${item['quantity']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.point_of_sale, color: Colors.teal),
                  onPressed: () async {
                    final result = await _showSaleDialog(context, item);
                    if (result != null) _recordSale(item, result);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Total Sales: ${totalSales.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<int?> _showSaleDialog(
      BuildContext context, Map<String, dynamic> item) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sell ${item['name']}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Quantity Sold'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text);
              if (qty != null && qty > 0) {
                Navigator.pop(context, qty);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
