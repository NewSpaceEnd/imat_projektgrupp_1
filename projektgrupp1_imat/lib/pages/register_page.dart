import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final handler = Provider.of<ImatDataHandler>(context, listen: false);
      await handler.login(_userController.text.trim(), _passController.text);

      // Optionally set basic customer info and push to server
      final cust = Customer(
        _firstName.text,
        _lastName.text,
        '',
        '',
        _email.text,
        '',
        '',
        '',
      );
      handler.setCustomer(cust);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konto skapat')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel vid skapande: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(title: 'Skapa konto'),
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
              TextFormField(controller: _firstName, decoration: const InputDecoration(labelText: 'Förnamn')),
              TextFormField(controller: _lastName, decoration: const InputDecoration(labelText: 'Efternamn')),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'E-post')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : const Text('Skapa konto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
