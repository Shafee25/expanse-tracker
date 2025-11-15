import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_expanse_tracker/models/transaction_model.dart';
import 'package:intl/intl.dart';

class HiveDatabase extends ChangeNotifier {
  // --- Setup ---
  final Box<TransactionModel> _transactionBox = Hive.box<TransactionModel>(
    'transactions',
  );

  // --- Constants ---
  static const List<String> categories = [
    'Food',
    'Bills',
    'Groceries',
    'Shopping',
    'Transport',
    'Other',
  ];

  // --- State ---
  List<TransactionModel> _allTransactions = [];

  // --- Getters ---
  List<TransactionModel> get allTransactions => _allTransactions;

  double get totalIncome {
    return _allTransactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _allTransactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get balance => totalIncome - totalExpense;

  // Groups transactions by date for the home screen list
  Map<String, List<TransactionModel>> get groupedTransactions {
    Map<String, List<TransactionModel>> grouped = {};

    // Sort transactions by date, newest first
    List<TransactionModel> sortedTransactions = List.from(_allTransactions);
    sortedTransactions.sort((a, b) => b.date.compareTo(a.date));

    for (var tx in sortedTransactions) {
      // Use intl to format the date as a key, e.g., "Today", "Yesterday", "Oct 10, 2025"
      String dateKey;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

      if (txDate == today) {
        dateKey = 'Today';
      } else if (txDate == yesterday) {
        dateKey = 'Yesterday';
      } else {
        dateKey = DateFormat('MMM d, yyyy').format(tx.date);
      }

      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(tx);
      } else {
        grouped[dateKey] = [tx];
      }
    }
    return grouped;
  }

  // --- Chart Getters (for Analytics) ---

  // For Pie Chart
  Map<String, double> get categoryExpenseDistribution {
    Map<String, double> distribution = {};

    for (var category in categories) {
      distribution[category] = 0.0;
    }

    for (var tx in _allTransactions) {
      if (tx.type == 'expense' && distribution.containsKey(tx.category)) {
        distribution[tx.category] = distribution[tx.category]! + tx.amount;
      }
    }
    // Remove categories with 0 expense
    distribution.removeWhere((key, value) => value == 0.0);
    return distribution;
  }

  // For Bar Chart (Simple: 12 bars for last 12 months)
  // Returns a map where key=month index (1=Jan, 2=Feb), value=total expense
  Map<int, double> get monthlyExpenseSummary {
    Map<int, double> summary = {};
    final now = DateTime.now();

    for (var tx in _allTransactions) {
      // Check if the transaction is from the last 12 months
      if (tx.type == 'expense' &&
          tx.date.isAfter(now.subtract(const Duration(days: 365)))) {
        int month = tx.date.month;
        summary[month] = (summary[month] ?? 0.0) + tx.amount;
      }
    }
    return summary;
  }

  // --- Public Methods (CRUD) ---

  // Call this when the app starts
  void loadTransactions() {
    _allTransactions = _transactionBox.values.toList();
    // Notify listeners to update the UI
    notifyListeners();
  }

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
    loadTransactions(); // Reload and notify
  }

  // UPDATE an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    // Hive's 'put' method automatically handles updates
    // if the key (transaction.id) already exists.
    await _transactionBox.put(transaction.id, transaction);
    loadTransactions(); // Reload and notify
  }

  // Delete a transaction
  Future<void> deleteTransaction(TransactionModel transaction) async {
    await transaction
        .delete(); // Since it's a HiveObject, we can just delete it
    loadTransactions(); // Reload and notify
  }
}
