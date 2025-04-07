import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StockCalculatorPage extends StatefulWidget {
  final String planName;

  const StockCalculatorPage({super.key, required this.planName});

  @override
  State<StockCalculatorPage> createState() => _StockCalculatorPageState();
}

class _StockCalculatorPageState extends State<StockCalculatorPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedItems =
        prefs.getString('stock_items_${widget.planName}');
    if (savedItems != null) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(json.decode(savedItems));
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'stock_items_${widget.planName}', json.encode(_items));
  }

  final List<Color> availableColors = [
    Colors.red.shade100, // Slightly stronger red
    Colors.orange.shade100, // Slightly stronger orange
    Colors.purple.shade100, // Slightly stronger violet
    Colors.green.shade100, // Slightly stronger green
    Colors.yellow.shade100, // Slightly stronger yellow
    Colors.blue.shade100, // Slightly stronger blue
    const Color.fromARGB(255, 212, 212, 212), // Slightly stronger gray
    Colors.white, // Base white color
    Colors.red.shade50, // Much softer red
    Colors.blue.shade50, // Much softer blue
    Colors.green.shade50, // Much softer green
    Colors.yellow.shade50, // Much softer yellow
    Colors.orange.shade50, // Much softer orange
    Colors.pink.shade50, // Much softer pink
  ];

  void _showNewItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final selectedColorNotifier =
        ValueNotifier<Color>(Colors.white); // Use ValueNotifier

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            // Wrap content to make it scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                const Text('Select Color:', style: TextStyle(fontSize: 14)),
                ValueListenableBuilder<Color>(
                  valueListenable: selectedColorNotifier,
                  builder: (context, selectedColor, child) {
                    return Wrap(
                      spacing: 5,
                      children: availableColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            selectedColorNotifier.value =
                                color; // Update selected color
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical:
                                    5), // Top and bottom space for each color
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26, // Light shadow color
                                    blurRadius: 3, // Soft shadow
                                    offset: Offset(2, 2), // Shadow offset
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final double? price = double.tryParse(priceController.text);

                if (name.isNotEmpty && price != null) {
                  setState(() {
                    _items.add({
                      'name': name,
                      'price': price,
                      'quantity': 0,
                      'color': selectedColorNotifier.value.value
                          .toRadixString(16), // Store color as hex
                    });
                  });
                  _saveItems();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditQuantityDialog(int index) {
    final qtyController = TextEditingController(
      text: _items[index]['quantity'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Quantity'),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter Quantity',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final int? newQty = int.tryParse(qtyController.text);
                if (newQty != null && newQty >= 0) {
                  setState(() {
                    _items[index]['quantity'] = newQty;
                  });
                  _saveItems();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllItems() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete All'),
          content: const Text('Are you sure you want to delete all items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('stock_items');
                setState(() {
                  _items.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _saveItems();
  }

  void _increaseQuantity(int index) {
    setState(() {
      _items[index]['quantity'] = (_items[index]['quantity'] ?? 0) + 1;
    });
    _saveItems();
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (_items[index]['quantity'] != null && _items[index]['quantity'] > 0) {
        _items[index]['quantity']--;
      }
    });
    _saveItems();
  }

  double _calculateTotalPrice() {
    return _items.fold(
        0,
        (sum, item) =>
            sum + (item['price'] as double) * (item['quantity'] as int? ?? 0));
  }

  void _showEditItemDialog(int index) {
    final nameController = TextEditingController(text: _items[index]['name']);
    final priceController =
        TextEditingController(text: _items[index]['price'].toString());
    // Using ValueNotifier for selected color
    final ValueNotifier<Color> selectedColorNotifier = ValueNotifier<Color>(
      Color(int.parse(_items[index]['color'] ?? 'FFFFFFFF', radix: 16)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              const Text('Select Color:', style: TextStyle(fontSize: 14)),
              ValueListenableBuilder<Color>(
                valueListenable: selectedColorNotifier,
                builder: (context, selectedColor, child) {
                  return Wrap(
                    spacing: 5,
                    children: availableColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          selectedColorNotifier.value =
                              color; // Update selected color
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical:
                                  5), // Top and bottom space for each color
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26, // Light shadow color
                                  blurRadius: 3, // Soft shadow
                                  offset: Offset(2, 2), // Shadow offset
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final double? price = double.tryParse(priceController.text);

                if (name.isNotEmpty && price != null) {
                  setState(() {
                    _items[index]['name'] = name;
                    _items[index]['price'] = price;
                    _items[index]['color'] =
                        selectedColorNotifier.value.value.toRadixString(16);
                  });
                  _saveItems();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Calculator'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final totalPrice =
                      (item['price'] as double) * (item['quantity'] as int);
                  return Dismissible(
                    key: Key('${item['name']}$index'),
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 33, 33),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 54, 133, 244),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this item?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (direction == DismissDirection.endToStart) {
                        _showEditItemDialog(index);
                        return false;
                      }
                      return false;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        _deleteItem(index);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Color(int.parse(item['color'] ?? 'FFFFFFFF',
                            radix: 16)), // Default white
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0), // Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // Smaller font size
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Price: ${item['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 12), // Smaller font size
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        _showEditQuantityDialog(index),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2), // Even smaller padding
                                      backgroundColor: Colors
                                          .transparent, // Transparent background for a flat look
                                      foregroundColor:
                                          Colors.black87, // Text color
                                      elevation:
                                          0, // No elevation for a flat button
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            4), // Smaller, sharper corners
                                      ),
                                      side: BorderSide(
                                        color: Colors.black.withOpacity(
                                            0.1), // Very subtle border
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Qty: ${item['quantity']}',
                                      style: const TextStyle(
                                        fontSize: 13, // Smaller font size
                                        fontWeight: FontWeight
                                            .w700, // Subtle boldness for the text
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Total Price: ${totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13, // Smaller font size
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _decreaseQuantity(index),
                                        icon: const Icon(Icons.remove_circle,
                                            size: 24, color: Colors.redAccent),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _increaseQuantity(index),
                                        icon: const Icon(Icons.add_circle,
                                            size: 24, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 10),
              height: _isMenuExpanded ? 65 : 0,
              curve: Curves.easeInOut,
              child: OverflowBox(
                maxHeight: 65, // Prevents overflow
                alignment: Alignment.topCenter,
                child: AnimatedOpacity(
                  opacity: _isMenuExpanded ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionBox(
                          icon: Icons.add,
                          label: 'Add',
                          onTap: _showNewItemDialog,
                        ),
                        _actionBox(
                          icon: Icons.delete,
                          label: 'Clear',
                          onTap: _deleteAllItems,
                        ),
                        _actionBox(
                          icon: Icons.save,
                          label: 'Save',
                          onTap: _saveItems,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _isMenuExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMenuExpanded = !_isMenuExpanded;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overall Total:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' ${_calculateTotalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Flexible(
      // Changed from Expanded to Flexible for better control
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: const Color.fromARGB(0, 255, 255, 255),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 50,
                maxHeight: 50,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: Colors.teal),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
