import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/budget_cubit.dart';
import 'services/storage_service.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Init Hive storage
  final storage = StorageService();
  await storage.init();

  runApp(BudgetFlowApp(storage: storage));
}

class BudgetFlowApp extends StatelessWidget {
  final StorageService storage;

  const BudgetFlowApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BudgetCubit(storage)..loadCurrentMonth(),
      child: MaterialApp(
        title: 'BudgetFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}