import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/user.dart';
import 'package:imat_app/model/internet_handler.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/auth_shell.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _stepKeys = List.generate(3, (_) => GlobalKey<FormState>());

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _addressController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _cityController = TextEditingController();

  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _cvcController = TextEditingController();

  int _currentStep = 0;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _postCodeController.dispose();
    _cityController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    if (!_stepKeys[_currentStep].currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    setState(() => _loading = true);
    try {
      final handler = Provider.of<ImatDataHandler>(context, listen: false);

      final user = User(_emailController.text.trim(), _passwordController.text);
      final customer = Customer(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim(),
        _addressController.text.trim(),
        _postCodeController.text.trim(),
        _cityController.text.trim(),
      );
      final card = CreditCard(
        'CARD',
        _cardHolderController.text.trim(),
        int.tryParse(_monthController.text.trim()) ?? 1,
        int.tryParse(_yearController.text.trim()) ?? 26,
        _cardNumberController.text.trim(),
        int.tryParse(_cvcController.text.trim()) ?? 0,
      );

      await InternetHandler.setUser(user);
      await InternetHandler.setCustomer(customer);
      await InternetHandler.setCreditCard(card);
      await handler.loadUserData();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konto skapat och betalningsuppgifter sparade')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel vid skapande: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Skapa konto',
      subtitle: 'Tre steg så att dina uppgifter, adress och betalning redan är klara när du kommer till kassan.',
      maxWidth: 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepIndicator(currentStep: _currentStep),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Form(
              key: _stepKeys[_currentStep],
              child: _buildStepContent(_currentStep),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentStep > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: Colors.grey.shade400),
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('Tillbaka'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PrimaryActionButton(
                  onPressed: _loading ? null : _advance,
                  label: _loading ? 'Sparar...' : (_currentStep == 2 ? 'Skapa konto' : 'Nästa'),
                  icon: _currentStep == 2 ? Icons.check_circle_outline : Icons.arrow_forward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loading ? null : () => Navigator.pop(context),
            child: const Text('Jag har redan ett konto'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _SectionCard(
          key: const ValueKey('step-0'),
          title: 'Info om dig',
          description: 'Grunduppgifter och inloggning för ditt konto.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _field(_firstNameController, label: 'Förnamn', validator: _required)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_lastNameController, label: 'Efternamn', validator: _required)),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                _emailController,
                label: 'E-post',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'E-post krävs';
                  if (!value.contains('@')) return 'Ange en giltig e-post';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _field(_phoneController, label: 'Telefonnummer', keyboardType: TextInputType.phone, validator: _required),
              const SizedBox(height: 12),
              _field(_passwordController, label: 'Lösenord', obscureText: true, validator: _required),
            ],
          ),
        );
      case 1:
        return _SectionCard(
          key: const ValueKey('step-1'),
          title: 'Adress',
          description: 'Adressen sparas så den redan är ifylld när du går till kassan.',
          child: Column(
            children: [
              _field(_addressController, label: 'Gatuadress', validator: _required),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field(_postCodeController, label: 'Postnummer', keyboardType: TextInputType.number, validator: _required)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_cityController, label: 'Postort', validator: _required)),
                ],
              ),
            ],
          ),
        );
      default:
        return _SectionCard(
          key: const ValueKey('step-2'),
          title: 'Betalning',
          description: 'Kortuppgifter som kan återanvändas direkt i kassan.',
          child: Column(
            children: [
              _field(_cardHolderController, label: 'Kortinnehavare', validator: _required),
              const SizedBox(height: 12),
              _field(
                _cardNumberController,
                label: 'Kortnummer',
                keyboardType: TextInputType.number,
                validator: _required,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field(_monthController, label: 'Månad', keyboardType: TextInputType.number, validator: _required)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_yearController, label: 'År', keyboardType: TextInputType.number, validator: _required)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_cvcController, label: 'CVC', keyboardType: TextInputType.number, validator: _required)),
                ],
              ),
            ],
          ),
        );
    }
  }

  Widget _field(
    TextEditingController controller, {
    required String label,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Fältet är obligatoriskt';
    return null;
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = const ['Info om dig', 'Adress', 'Betalning'];

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index == currentStep;
        final isComplete = index < currentStep;

        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete ? Colors.green : isActive ? const Color(0xFF1E6AF0) : Colors.grey.shade300,
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.black87 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _SectionCard({required super.key, required this.title, required this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EAF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
