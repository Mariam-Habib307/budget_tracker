import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.teal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              // Logo area
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              const Text(
                'BudgetFlow',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                'Master Your Money, Daily',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              const Spacer(),
              // Illustration area
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 100,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1),
              const Spacer(),
              // Feature pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _featurePill('Track Budgets'),
                  const SizedBox(width: 8),
                  _featurePill('Monitor Spending'),
                  const SizedBox(width: 8),
                  _featurePill('Save More'),
                ],
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.teal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featurePill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
