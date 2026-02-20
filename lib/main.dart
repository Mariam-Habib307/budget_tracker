import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'cubit/budget_cubit.dart';
import 'cubit/budget_state.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize HydratedBloc storage
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  HydratedBloc.storage = storage;

  runApp(const BudgetFlowApp());
}

class BudgetFlowApp extends StatelessWidget {
  const BudgetFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = BudgetCubit();
        // If state is still initial after hydration, load defaults
        if (cubit.state is BudgetInitial) {
          cubit.loadBudgets();
        }
        return cubit;
      },
      child: MaterialApp(
        title: 'BudgetFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, state) {
            if (state is BudgetLoaded) {
              // First time user: show welcome screen
              // Returning user: go straight to dashboard
              // We use the transaction count as a heuristic
              return const DashboardScreen();
            }
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}