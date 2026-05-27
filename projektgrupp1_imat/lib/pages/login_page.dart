import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/auth_shell.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

const double loginPageTitleTextSize = 22.0;
const double loginPageSubtitleTextSize = 14.0;
const double loginPageSectionTitleTextSize = 17.0;
const double loginPageFieldLabelTextSize = 14.0;
const double loginPageFieldTextSize = 16.0;
const double loginPageButtonTextSize = 18.0;
const double loginPageErrorTextSize = 13.0;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final start = DateTime.now();
    try {
      final handler = Provider.of<ImatDataHandler>(context, listen: false);
      await handler.login(_userController.text.trim(), _passController.text);
      if (!mounted) return;
      // Ensure the login UI state ("Loggar in...") is visible for at least 3 seconds
      final elapsed = DateTime.now().difference(start);
      final minDuration = const Duration(seconds: 3);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      if (mounted) {
        setState(() => _errorMessage = null);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      // Even on error, keep the loading state visible for minimum duration so user sees feedback
      final elapsed = DateTime.now().difference(start);
      final minDuration = const Duration(seconds: 3);
      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }
      if (mounted) setState(() => _errorMessage = 'Fel vid inloggning: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Login',
      subtitle: '',
      titleTextSize: loginPageTitleTextSize,
      subtitleTextSize: loginPageSubtitleTextSize,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Inloggningsuppgifter',
              style: TextStyle(fontSize: loginPageSectionTitleTextSize, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _userController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'Enter email',
                labelStyle: TextStyle(fontSize: loginPageFieldLabelTextSize),
                hintStyle: TextStyle(fontSize: loginPageFieldTextSize),
              ),
              style: const TextStyle(fontSize: loginPageFieldTextSize),
              validator: (v) => (v == null || v.isEmpty) ? 'E-post krävs' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
                labelStyle: TextStyle(fontSize: loginPageFieldLabelTextSize),
                hintStyle: TextStyle(fontSize: loginPageFieldTextSize),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: loginPageFieldTextSize),
              validator: (v) => (v == null || v.isEmpty) ? 'Lösenord krävs' : null,
            ),
            const SizedBox(height: 20),
            PrimaryActionButton(
              onPressed: _loading ? null : _submit,
              label: _loading ? 'Loggar in...' : 'Login',
              icon: Icons.login,
              textSize: loginPageButtonTextSize,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: loginPageErrorTextSize)),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Skapa konto', style: TextStyle(fontSize: loginPageButtonTextSize)),
            ),
          ],
        ),
      ),
    );
  }
}
