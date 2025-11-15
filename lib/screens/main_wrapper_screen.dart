import 'package:my_expanse_tracker/screens/add_transaction_screen.dart';
import 'package:my_expanse_tracker/screens/analytics_screen.dart';
import 'package:my_expanse_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [const HomeScreen(), const AnalyticsScreen()];

  // Show the AddTransactionScreen as a modal bottom sheet
  void _onFabTapped() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddTransactionScreen(
          transaction: null, // <-- Pass null to signify "Add Mode"
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      extendBody: true, // Allows body to go behind the nav bar
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabTapped,
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurple.shade400,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Nav Item
              _buildNavItem(Icons.home_filled, 'Home', 0),
              // Right Nav Item
              _buildNavItem(Icons.bar_chart, 'Analytics', 1),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build a single nav bar item
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected
        ? Colors.deepPurple.shade400
        : Colors.grey.shade500;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            // const SizedBox(height: 1), // <-- FIX: Removed this 1px spacer
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
