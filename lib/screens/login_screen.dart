import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  void _login() async {
    if (_idController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          studentId: _idController.text.trim(),
          studentName: 'Somsak T.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.school_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Smart Check-in',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to your student account',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),

              // Divider
              const Divider(color: AppColors.border, thickness: 0.5),
              const SizedBox(height: 24),

              // Student ID
              Align(
                alignment: Alignment.centerLeft,
                child: Text('STUDENT ID',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '640XXXXXXX',
                  prefixIcon: Icon(Icons.badge_outlined,
                      size: 20, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              Align(
                alignment: Alignment.centerLeft,
                child: Text('PASSWORD',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline,
                      size: 20, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textTertiary),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign in button
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Sign in'),
              ),
              const SizedBox(height: 16),

              // OR divider
              Row(children: [
                const Expanded(
                    child: Divider(color: AppColors.border, thickness: 0.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary)),
                ),
                const Expanded(
                    child: Divider(color: AppColors.border, thickness: 0.5)),
              ]),
              const SizedBox(height: 16),

              // Microsoft SSO
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.grid_view_rounded,
                    size: 18, color: AppColors.blue),
                label: const Text('Sign in with Microsoft'),
              ),
              const SizedBox(height: 32),

              // Forgot password
              Text(
                'Forgot password? Contact your instructor',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
