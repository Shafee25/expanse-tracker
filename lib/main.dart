import 'package:my_expanse_tracker/database/hive_database.dart';
import 'package:my_expanse_tracker/models/transaction_model.dart';
import 'package:my_expanse_tracker/screens/main_wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // <-- WE ADDED THIS FOR WEB

void main() async {
  // --- HIVE DATABASE SETUP ---

  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive differently for Web vs. Mobile
  if (kIsWeb) {
    // For web, just initialize Hive. It uses IndexedDB automatically.
    await Hive.initFlutter();
  } else {
    // For mobile (Android/iOS), get a folder to store the data
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  // 3. Register our "blueprint" (Adapter)
  Hive.registerAdapter(TransactionModelAdapter());

  // 4. Open the "toy box" (Box)
  await Hive.openBox<TransactionModel>('transactions');

  // --- RUN THE APP ---
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the app in our "magic helper" (Provider)
    return ChangeNotifierProvider(
      create: (context) => HiveDatabase(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          // --- THIS IS THE REAL FIX ---
          // We are telling Flutter to use a generic font
          // that is already built into the browser,
          // which requires NO download.
          fontFamily: 'sans-serif',

          // --- END OF FIX ---
          scaffoldBackgroundColor: const Color(0xFFF4F6F8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black87,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainWrapperScreen(),
      ),
    );
  }
}