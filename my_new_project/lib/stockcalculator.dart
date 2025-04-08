// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StockCalculatorPage extends StatefulWidget {
  final String planName;
  final String planDate;

  const StockCalculatorPage({
    super.key,
    required this.planName,
    required this.planDate,
  });

  // Method to format the date
  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.tryParse(date);
      if (parsedDate != null) {
        return DateFormat('MMMM d, y').format(parsedDate); // Format the date
      } else {
        return date; // If parsing fails, return the original string
      }
    } catch (e) {
      return date; // If there's any error, return the original string
    }
  }

  @override
  State<StockCalculatorPage> createState() => _StockCalculatorPageState();
}

class ActionBox extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionBox({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ActionBox> createState() => _ActionBoxState();
}

class _ActionBoxState extends State<ActionBox> {
  Color _bgColor = Colors.white;

  void _handleTap() {
    setState(() => _bgColor = Colors.teal.withOpacity(0.2)); // highlight
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _bgColor = Colors.white); // back to normal
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 50,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 18, color: Colors.teal),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 9,
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

// this method is for color selection
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

  Future<void> _saveAsTemplate(String templateName) async {
    final prefs = await SharedPreferences.getInstance();

    // Save the items as a template
    await prefs.setString(
      'stock_items_template_$templateName',
      json.encode(_items), // Save the items as a JSON string
    );
  }

  // this method shows a dialog to enter a template name
  // it returns the entered template name and save the template
  // if the user clicks on save button
  Future<String?> _showTemplateNameDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Template Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Template Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text); // Save
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // this method shows a dialog to select a template from the saved templates
  // it returns the selected template name
  Future<String?> _showTemplateSelectDialog(
      BuildContext context, List<String> templates) async {
    // Create a local copy of templates that we can modify
    List<String> localTemplates = List.from(templates);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select a Template'),
              content: SizedBox(
                width: 300, // Set a fixed width for both dialogs
                height: 250, // Reduced height for a more compact dialog
                child: SingleChildScrollView(
                  child: ListBody(
                    children: localTemplates.map((template) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file,
                              color: Colors.blue),
                          title: Text(template),
                          trailing: Container(
                            padding: const EdgeInsets.only(
                                right:
                                    0), // Adjust padding to move icon closer to edge
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final shouldDelete =
                                    await _showDeleteConfirmationDialog(
                                        context, template);
                                if (shouldDelete ?? false) {
                                  await _deleteTemplate(template);
                                  setState(() {
                                    localTemplates.remove(template);
                                  });
                                }
                              },
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pop(template); // Return selected template
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(
      BuildContext context, String template) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Template'),
          content: SizedBox(
            width: 300, // Set a fixed width for both dialogs
            height: 40, // Reduced height for delete confirmation
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Are you sure you want to delete this template?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTemplate(String template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stock_items_template_$template');
    // Force a UI refresh
    if (mounted) {
      setState(() {});
    }
  }

  // this method loads the saved templates from the shared preferences
  // it returns a list of template names
  Future<List<String>> _loadSavedTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templateKeys = prefs
        .getKeys()
        .where((key) => key.startsWith('stock_items_template_'))
        .toList();

    // Extract template names from the keys and return them as a list
    return templateKeys
        .map((key) => key.replaceFirst('stock_items_template_', ''))
        .toList();
  }

// this method loads the template data from the shared preferences
  // it returns the loaded template data and updates the state of the app
  Future<void> _loadTemplateData(String templateName) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the saved template data
    final savedTemplate = prefs.getString('stock_items_template_$templateName');
    if (savedTemplate != null) {
      List<Map<String, dynamic>> templateItems =
          List<Map<String, dynamic>>.from(json.decode(savedTemplate));
      // Optionally, update your app's state with the loaded template data
      setState(() {
        _items = templateItems;
      });
    } else {}
  }

  //to sort the items alphabetically
  void _sortItemsAlphabetically() {
    setState(() {
      _items.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));
    });
    _saveItems();
  }

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
        //delete confirmation dialog
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

  void _clearAllQty() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Quantities'),
          content: const Text(
              'Are you sure you want to clear the quantity for all items?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear all quantities
                setState(() {
                  for (var item in _items) {
                    item['quantity'] = 0;
                  }
                });
                _saveItems(); // Save the updated state to storage
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
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
    final formattedDate = widget._formatDate(widget.planDate);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Calculator'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Display the plan name and date
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  children: [
                    const TextSpan(
                      text: '📋 ',
                      style: TextStyle(fontSize: 20),
                    ),
                    TextSpan(
                      text: widget.planName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '  •  '),
                    TextSpan(
                      text: formattedDate,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final sortedItems = List<Map<String, dynamic>>.from(_items)
                    ..sort((a, b) => (a['name'] as String)
                        .toLowerCase()
                        .compareTo((b['name'] as String).toLowerCase()));
                  final item = _items[index];
                  final totalPrice =
                      (item['price'] as double) * (item['quantity'] as int);
                  return Dismissible(
                    key: Key('${item['name']}$index'),
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 54, 133, 244),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 33, 33),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
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
                      } else if (direction == DismissDirection.startToEnd) {
                        _showEditItemDialog(index);
                        return false;
                      }
                      return false;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
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
                        ActionBox(
                          icon: Icons.add,
                          label: 'Add',
                          onTap: _showNewItemDialog,
                        ),
                        ActionBox(
                          icon: Icons.sort_by_alpha,
                          label: 'Sort',
                          onTap: _sortItemsAlphabetically,
                        ),
                        ActionBox(
                          icon: Icons.delete,
                          label: 'Delete All',
                          onTap: _deleteAllItems,
                        ),
                        ActionBox(
                          icon: Icons.cleaning_services_rounded,
                          label: 'Clear All',
                          onTap: _clearAllQty,
                        ),
                        ActionBox(
                          icon: Icons.save,
                          label: 'Save',
                          onTap: () async {
                            String? templateName =
                                await _showTemplateNameDialog(context);
                            if (templateName != null &&
                                templateName.isNotEmpty) {
                              await _saveAsTemplate(
                                  templateName); // Pass the templateName
                            }
                          },
                        ),
                        ActionBox(
                          // create a new action box for loading saved templates
                          icon: Icons.folder_open,
                          label: 'Load',
                          onTap: () async {
                            List<String> templates =
                                await _loadSavedTemplates(); // Fetch saved templates
                            if (templates.isEmpty) {
                            } else {
                              String? selectedTemplate =
                                  await _showTemplateSelectDialog(
                                      context, templates);
                              if (selectedTemplate != null) {
                                // Load the selected template data
                                // Optionally, you can load the data of the selected template here
                                await _loadTemplateData(selectedTemplate);
                              }
                            }
                          },
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
}
