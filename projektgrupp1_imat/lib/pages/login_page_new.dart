import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

const double loginPageNewTitleTextSize = 22.0;
const double loginPageNewSectionTitleTextSize = 17.0;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final handler = Provider.of<ImatDataHandler>(context, listen: false);
      await handler.login(_userController.text.trim(), _passController.text);
      if (!mounted) return;
      if (mounted) {
        setState(() => _errorMessage = null);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Fel vid inloggning: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Logga in',
                style: TextStyle(fontSize: loginPageNewTitleTextSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Inloggningsuppgifter', style: TextStyle(fontSize: loginPageNewSectionTitleTextSize, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _userController,
                        decoration: const InputDecoration(labelText: 'Användarnamn'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Användarnamn krävs' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passController,
                        decoration: const InputDecoration(labelText: 'Lösenord'),
                        obscureText: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'Lösenord krävs' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PrimaryActionButton(
                      onPressed: _loading ? null : _submit,
                      label: 'Logga in',
                      icon: Icons.login,
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Skapa nytt konto istället'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8B5CF6),
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
