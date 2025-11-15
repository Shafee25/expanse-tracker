import 'package:my_expanse_tracker/database/hive_database.dart';
import 'package:my_expanse_tracker/models/transaction_model.dart';
import 'package:my_expanse_tracker/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionTile({super.key, required this.transaction});

  // --- Edit Action ---
  void _onEditTapped(BuildContext context) {
    // Show the AddTransactionScreen in "Edit" mode
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddTransactionScreen(
          transaction: transaction, // <-- Pass the transaction to edit
        );
      },
    );
  }

  // --- Delete Action ---
  void _onDeleteTapped(BuildContext context) {
    // Get the database and call the delete method
    // 'listen: false' is important here because we are in a method, not 'build'
    final db = Provider.of<HiveDatabase>(context, listen: false);
    db.deleteTransaction(transaction);
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == 'expense';
    final Color color = isExpense ? Colors.red.shade700 : Colors.green.shade700;
    final String sign = isExpense ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Slidable(
        // --- Slidable Actions (Edit, Delete) ---
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // Edit Action
            SlidableAction(
              onPressed: _onEditTapped,
              icon: Icons.edit,
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            // Delete Action
            SlidableAction(
              onPressed: _onDeleteTapped,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        // --- The Main Tile Content ---
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
              ),
            ),
            title: Text(
              transaction.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${transaction.category} • ${DateFormat('h:mm a').format(transaction.date)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            trailing: Text(
              '$sign Rs. ${transaction.amount.toStringAsFixed(2)}', // <-- CURRENCY CHANGED
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
