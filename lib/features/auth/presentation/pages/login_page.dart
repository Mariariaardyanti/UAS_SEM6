import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/auth_header.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_button.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/divider_with_text.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
 
  static const String _logoUrl =
      'https://i.ibb.co.com/0VWk0BDJ/36581ebf-d1b2-4e22-8d18-b6b19368c6f3-removebg-preview.png';

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Handler untuk login email/password
  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  /// Handler untuk login Google
  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  /// Routing berdasarkan hasil login
  void _handleLoginResult(bool ok, AuthProvider auth) {
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: CustomTextField(
          label: 'Email',
          hint: 'Email terdaftar',
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: ctrl.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final isLoading = context.watch<AuthProvider>().isLoading;

  return LoadingOverlay(
    isLoading: isLoading,
    message: 'Masuk ke akun...',
    child: Scaffold(
      backgroundColor: const Color(0xFFFFF3E6), 

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),

                
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    _logoUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 84,
                        height: 84,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.deepOrange,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 36,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // HEADER (lebih cute feel)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const AuthHeader(
                    icon: Icons.shopping_bag_outlined, 
                    title: 'Halo, Fashion Lovers ',
                    subtitle: 'Yuk masuk ke toko tas lucu kamu',
                  ),
                ),

                const SizedBox(height: 28),

                // EMAIL FIELD
                CustomTextField(
                  label: 'Email',
                  hint: 'contoh@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Email wajib diisi';
                    if (!EmailValidator.validate(v!)) {
                      return 'Format email salah';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PASSWORD FIELD
                CustomTextField(
                  label: 'Password',
                  hint: 'Masukkan password',
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  prefixIcon: const Icon(Icons.key_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPass
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'Password wajib diisi' : null,
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    child: const Text(
                      'Lupa password? ',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                //LOGIN BUTTON
                CustomButton(
                  label: 'Masuk ',
                  onPressed: _loginEmail,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 20),

                const DividerWithText(text: 'atau masuk dengan'),

                const SizedBox(height: 20),

                // 🌼 GOOGLE BUTTON (lebih cute feel)
                GoogleSignInButton(
                  onPressed: _loginGoogle,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                //  REGISTER
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? '),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.register,
                        ),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}