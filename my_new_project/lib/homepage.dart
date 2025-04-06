import 'package:flutter/material.dart';
import 'drawer.dart'; // Import your custom drawer
import 'stockcalculator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isStockCalculatorTapped = false;

  Widget _buildInfoCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withAlpha((0.2 * 255).toInt()),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Image.asset(
          'assets/logo.png',
          height: 40,
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coreteam Tools Box
            GestureDetector(
              onTap: () {
                // Optional: You can do something here
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coreteam Tools',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Stock Calculator with tap animation
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isStockCalculatorTapped = true;
                              });

                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (mounted) {
                                  setState(() {
                                    _isStockCalculatorTapped = false;
                                  });
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const StockCalculatorPage()),
                                );
                              });
                            },
                            child: AnimatedScale(
                              scale: _isStockCalculatorTapped ? 0.95 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _isStockCalculatorTapped
                                      ? Colors.green.shade100
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey
                                          .withAlpha((0.5 * 255).toInt()),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.calculate,
                                      size: 32,
                                      color: Colors.green,
                                    ),
                                    SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        'Stock Calculator',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Task Manager (no animation)
                          GestureDetector(
                            onTap: () {
                              // Add animation or action if needed
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.task,
                                    size: 32,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      'Task Manager',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Info Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 4 / 1.5,
                children: [
                  _buildInfoCard('Total Sales Today', '\$1,200', Colors.green,
                      Icons.attach_money),
                  _buildInfoCard(
                      'Total Stocks', '1,500', Colors.orange, Icons.inventory),
                  _buildInfoCard('Receipts', '250', Colors.blue, Icons.receipt),
                  _buildInfoCard('Documents', '10', Colors.red, Icons.folder),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
