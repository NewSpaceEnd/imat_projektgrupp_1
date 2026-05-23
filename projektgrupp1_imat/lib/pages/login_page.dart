import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/auth_shell.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

const double loginPageSectionTitleTextSize = 17.0;

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
    return AuthShell(
      title: 'Login',
      subtitle: 'Logga in för att fortsätta till dina sparade varor, orderhistorik och kassan.',
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
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'E-post krävs' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Password',
              ),
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Lösenord krävs' : null,
            ),
            const SizedBox(height: 20),
            PrimaryActionButton(
              onPressed: _loading ? null : _submit,
              label: _loading ? 'Loggar in...' : 'Login',
              icon: Icons.login,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Skapa konto'),
            ),
          ],
        ),
      ),
    );
  }
}
