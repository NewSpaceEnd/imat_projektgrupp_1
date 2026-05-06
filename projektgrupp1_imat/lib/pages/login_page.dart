import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inloggning klar')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel vid inloggning: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(title: 'Logga in'),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Användarnamn'),
                validator: (v) => (v == null || v.isEmpty) ? 'Användarnamn krävs' : null,
              ),
              TextFormField(
                controller: _passController,
                decoration: const InputDecoration(labelText: 'Lösenord'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Lösenord krävs' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Logga in'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Skapa konto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
