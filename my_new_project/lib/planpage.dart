import 'package:ctapp/stockcalculator.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MyPlansPage extends StatefulWidget {
  const MyPlansPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyPlansPageState createState() => _MyPlansPageState();
}

class _MyPlansPageState extends State<MyPlansPage> {
  List<String> savedPlans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/plans.txt');
  }

  Future<void> _loadPlans() async {
    try {
      final file = await _getLocalFile();
      if (!(await file.exists())) {
        await file.create();
      }

      final contents = await file.readAsString();
      setState(() {
        savedPlans = contents.isNotEmpty ? contents.split('\n') : [];
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading plans: $e');
    }
  }

  Future<void> _savePlans() async {
    try {
      final file = await _getLocalFile();
      final contents = savedPlans.join('\n');
      await file.writeAsString(contents);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving plans: $e');
    }
  }

  Future<void> _deletePlan(int index) async {
    setState(() {
      savedPlans.removeAt(index);
    });
    await _savePlans();
  }

  Future<void> _editPlan(int index) async {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final planParts = savedPlans[index].split(',');
    final name = planParts[0].split(':')[1].trim().replaceAll("'", "");
    final date = planParts[1].split(':')[1].trim().replaceAll("'", "");

    nameController.text = name;
    selectedDate = DateTime.parse(date);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final updatedPlan = {
                    'name': nameController.text,
                    'date': selectedDate.toLocal().toString(),
                  };
                  savedPlans[index] = updatedPlan.toString();
                  await _savePlans();
                  Navigator.pop(context);
                  _loadPlans();
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.blueAccent.shade100,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Manage Your Plans',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildExpandableButton(
                            context,
                            title: 'New Plan',
                            icon: Icons.add_circle_outline,
                            onPressed: () {
                              _showNewPlanDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Here are your plans!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...savedPlans.asMap().entries.map((entry) {
                        int index = entry.key;
                        String plan = entry.value;
                        return _buildPlanCard(plan, index);
                      })
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String plan, int index) {
    try {
      final parts = plan.split(',');
      if (parts.length < 2) {
        return _buildErrorCard(index);
      }

      final name = parts[0].split(':')[1].trim().replaceAll("'", "");
      final date = parts[1].split(':')[1].trim().replaceAll("'", "");

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading:
              Icon(Icons.calendar_today, color: Colors.blueAccent.shade200),
          title: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            date,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editPlan(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _deletePlan(index),
              ),
              // In the _buildPlanCard method, modify the onPressed for the calculator icon:
              IconButton(
                icon: const Icon(Icons.calculate, size: 20),
                tooltip: 'Stock Calculator',
                onPressed: () async {
                  final planParts = savedPlans[index].split(',');
                  final name =
                      planParts[0].split(':')[1].trim().replaceAll("'", "");

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockCalculatorPage(planName: name),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      savedPlans.add(result);
                    });
                    await _savePlans();
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return _buildErrorCard(index);
    }
  }

  Widget _buildErrorCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: const Icon(Icons.error_outline, color: Colors.red, size: 30),
        title: const Text(
          'Invalid Plan Data',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        subtitle: const Text(
          'There was an error loading this plan.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deletePlan(index),
        ),
      ),
    );
  }

  Future<void> _showNewPlanDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        selectedDate = picked;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final newPlan = {
                    'name': nameController.text,
                    'date': selectedDate.toLocal().toString(),
                  };
                  setState(() {
                    savedPlans.add(newPlan.toString());
                  });
                  await _savePlans();
                  Navigator.pop(context);
                  _loadPlans();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandableButton(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy StockCalculatorScreen so it works
class StockCalculatorScreen extends StatelessWidget {
  const StockCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Calculator")),
      body: const Center(child: Text("This is the stock calculator screen.")),
    );
  }
}
