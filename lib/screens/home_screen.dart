import 'package:my_expanse_tracker/database/hive_database.dart';
import 'package:my_expanse_tracker/widgets/transaction_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // <-- We remove this to fix the web crash
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use Consumer to listen to changes in our database
    return Consumer<HiveDatabase>(
      builder: (context, db, child) {
        final groupedTransactions = db.groupedTransactions;
        final dateKeys = groupedTransactions.keys.toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // --- Header with Balance Card ---
              SliverAppBar(
                expandedHeight: 260.0, // <-- FIX: Increased from 240 to 260
                backgroundColor: Colors.grey.shade50,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildBalanceCard(db),
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: const Text(
                    '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // --- Transaction List ---
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Check if we are at the end of the data
                    if (index >= dateKeys.length) {
                      // Show empty state if there are no transactions at all
                      return dateKeys.isEmpty ? _buildEmptyState() : null;
                    }

                    final dateKey = dateKeys[index];
                    final transactions = groupedTransactions[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Date Header ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            20.0,
                            16.0,
                            8.0,
                          ),
                          child: Text(
                            dateKey,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        // --- Transactions for that date ---
                        ...transactions.map((tx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: TransactionTile(transaction: tx),
                          );
                        }).toList(),
                      ],
                    );
                  },
                  // Add 1 to the count for the empty state widget if needed
                  childCount: dateKeys.isEmpty ? 1 : dateKeys.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Balance Card Widget ---
  Widget _buildBalanceCard(HiveDatabase db) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          // --- Balance Amount ---
          Text(
            'Rs. ${db.balance.toStringAsFixed(2)}',
            // <-- FIX: Removed GoogleFonts.poppins
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // --- Income vs Expense ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncomeExpenseRow(
                Icons.arrow_upward,
                'Income',
                'Rs. ${db.totalIncome.toStringAsFixed(2)}',
                Colors.greenAccent.shade400,
              ),
              _buildIncomeExpenseRow(
                Icons.arrow_downward,
                'Expense',
                'Rs. ${db.totalExpense.toStringAsFixed(2)}',
                Colors.red.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(
    IconData icon,
    String title,
    String amount,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Empty State Widget ---
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            CupertinoIcons.doc_plaintext,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the "+" button to add your first one!',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
