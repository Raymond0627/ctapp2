import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPlansPage extends StatefulWidget {
  const MyPlansPage({super.key});

  @override
  _MyPlansPageState createState() => _MyPlansPageState();
}

class _MyPlansPageState extends State<MyPlansPage> {
  List<String> savedPlans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  // Function to load saved plans from SharedPreferences
  Future<void> _loadPlans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPlans = prefs.getStringList('plans') ?? [];
    });
  }

  // Function to delete a plan
  Future<void> _deletePlan(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedPlans.removeAt(index);
    await prefs.setStringList('plans', savedPlans);
    _loadPlans(); // Reload the plans after deletion
  }

  // Function to delete invalid plan
  Future<void> _deleteInvalidPlan(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedPlans.removeAt(index); // Remove the invalid plan
    await prefs.setStringList('plans', savedPlans);
    _loadPlans(); // Reload the plans after deletion
  }

  // Function to edit a plan
  Future<void> _editPlan(int index) async {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final planParts = savedPlans[index].split(',');
    final name = planParts[0].split(':')[1].trim().replaceAll("'", "");
    final date = planParts[1].split(':')[1].trim().replaceAll("'", "");

    nameController.text = name;
    selectedDate = DateTime.parse(date);

    // Show dialog to edit the plan
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
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                ),
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
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the plan details
                if (nameController.text.isNotEmpty) {
                  final updatedPlan = {
                    'name': nameController.text,
                    'date': selectedDate.toLocal().toString(),
                  };

                  savedPlans[index] = updatedPlan.toString();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setStringList('plans', savedPlans);
                  Navigator.pop(context); // Close the dialog
                  _loadPlans(); // Reload plans
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
                          color: Colors.white),
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
            delegate: SliverChildListDelegate([
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
                    }).toList(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String plan, int index) {
    try {
      final parts = plan.split(',');

      if (parts.length < 2) {
        return _buildErrorCard(index); // Pass index to error card for deletion
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
          leading: Icon(
            Icons.calendar_today,
            color: Colors.blueAccent.shade200,
            size: 30,
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  _editPlan(index);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {
                  _deletePlan(index);
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return _buildErrorCard(
          index); // Return an error card if there's an issue with the parsing
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
        leading: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 30,
        ),
        title: const Text(
          'Invalid Plan Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        subtitle: const Text(
          'There was an error loading this plan.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteInvalidPlan(index); // Delete invalid plan
          },
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
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                ),
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
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final newPlan = {
                    'name': nameController.text,
                    'date': selectedDate.toLocal().toString(),
                  };
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  List<String> plans = prefs.getStringList('plans') ?? [];
                  plans.add(newPlan.toString());
                  await prefs.setStringList('plans', plans);
                  Navigator.pop(context); // Close the dialog
                  _loadPlans(); // Reload plans
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandableButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: _isPressed,
      builder: (context, isPressed, child) {
        return GestureDetector(
          onTap: () {
            _isPressed.value = true;
            Future.delayed(const Duration(milliseconds: 200), () {
              _isPressed.value = false;
            });
            onPressed();
          },
          child: AnimatedScale(
            scale: isPressed ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
          ),
        );
      },
    );
  }
}
