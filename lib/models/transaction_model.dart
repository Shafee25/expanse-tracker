import 'package:hive/hive.dart';

// This line is needed to auto-generate the file
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String type; // 'income' or 'expense'

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    required this.type,
  });
}