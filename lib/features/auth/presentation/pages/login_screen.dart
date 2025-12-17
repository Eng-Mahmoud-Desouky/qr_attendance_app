import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../home_screen.dart';
import '../../../../core/services/url_config_service.dart';
import '../../../../injection_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Check if already authenticated and navigate to home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  void _showUrlConfigDialog(BuildContext context) {
    final urlService = sl<UrlConfigService>();
    final urlController = TextEditingController(text: urlService.getBaseUrl());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings_ethernet, color: Colors.blue),
            SizedBox(width: 8),
            Text('Configure Base URL'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current URL:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  urlService.getBaseUrl(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'New Base URL',
                  hintText: 'http://192.168.1.100:8083',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Base URL';
                  }
                  if (!RegExp(
                    r'^https?://',
                    caseSensitive: false,
                  ).hasMatch(value)) {
                    return 'Must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Example: http://10.0.2.2:8083',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await urlService.resetToDefault();
              urlController.text = urlService.getBaseUrl();
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset to default URL'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await urlService.saveBaseUrl(
                  urlController.text,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Base URL saved successfully ✅\n${urlService.getBaseUrl()}'
                            : 'Failed to save Base URL ❌',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showUrlConfigDialog(context),
            tooltip: 'Configure Base URL',
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v!.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) => v!.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthCubit>().login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
