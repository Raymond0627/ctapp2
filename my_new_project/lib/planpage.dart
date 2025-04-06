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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with Expandable Menu
          SliverAppBar(
            expandedHeight: 150.0, // Reduced height to fit screen
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.blueAccent.shade100,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    const Text(
                      'Manage Your Plans',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Horizontal Scrollable Row for Buttons
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
                          const SizedBox(width: 10),
                          _buildExpandableButton(
                            context,
                            title: 'Edit Plan',
                            icon: Icons.edit,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Edit Plan button pressed')));
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildExpandableButton(
                            context,
                            title: 'Delete Plan',
                            icon: Icons.delete_outline,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Delete Plan button pressed')));
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
          // Content below the AppBar
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Move "Here are your plans!" to the center
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
                    // Display saved plans
                    ...savedPlans.map((plan) {
                      return _buildPlanCard(plan);
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

  // Function to display a card for each saved plan with name and date
  Widget _buildPlanCard(String plan) {
    try {
      final parts = plan.split(','); // Splitting the string into name and date

      if (parts.length < 2) {
        return _buildErrorCard(); // Return an error card if the plan is not in expected format
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
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Colors.blueAccent.shade200,
          ),
          onTap: () {
            // Optionally handle tap event (e.g., navigate to details screen)
          },
        ),
      );
    } catch (e) {
      return _buildErrorCard(); // Return an error card if there's an issue with the parsing
    }
  }

  // Function to display an error card when plan data is invalid
  Widget _buildErrorCard() {
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
      ),
    );
  }

  // Function to show dialog for creating a new plan
  Future<void> _showNewPlanDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    // Show dialog to get plan name and date
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
                // Save the plan details
                if (nameController.text.isNotEmpty) {
                  final newPlan = {
                    'name': nameController.text,
                    'date': selectedDate.toLocal().toString(),
                  };
                  // Save the plan to SharedPreferences (or a file)
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

  // Function to create a minimalist and expandable button with individual animation
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
            // Trigger the onPressed callback after animation
            Future.delayed(const Duration(milliseconds: 200), () {
              _isPressed.value = false; // Reset animation after 200ms
            });
            onPressed(); // Call the actual action
          },
          child: AnimatedScale(
            scale:
                isPressed ? 1.2 : 1.0, // Animate scale for the clicked button
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
                  Icon(icon, color: Colors.blue, size: 18), // Reduced icon size
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12, // Reduced font size
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
