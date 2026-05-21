import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

// Base class for step-based login/register pages
abstract class LoginRegisterBasePage extends StatefulWidget {
  const LoginRegisterBasePage({super.key});
}

abstract class LoginRegisterBaseState<T extends LoginRegisterBasePage> extends State<T> with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController animationController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  String getPageTitle();
  List<String> getStepNames();
  Widget buildStepContent(int step);
  Future<void> handleSubmit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                getPageTitle(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: buildStepContent(currentStep),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => currentStep--),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Tillbaka'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  if (currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryActionButton(
                      onPressed: _handleNavigation,
                      label: currentStep == getStepNames().length - 1 ? 'Slutför' : 'Nästa',
                      icon: currentStep == getStepNames().length - 1 ? Icons.check_circle_outline : Icons.arrow_forward,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNavigation() async {
    if (!formKey.currentState!.validate()) return;

    if (currentStep == getStepNames().length - 1) {
      await handleSubmit();
    } else {
      setState(() => currentStep++);
    }
  }

  Widget _buildProgressIndicator() {
    final steps = getStepNames();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF8B5CF6)
                          : isCompleted
                              ? Colors.green
                              : Colors.grey[300],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive || isCompleted ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
