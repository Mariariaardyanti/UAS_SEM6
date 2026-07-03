import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_button.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:pasar_malam/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color _accentOrange = Color(0xFFFF7A29);

  static const String _logoUrl =
      'https://i.ibb.co.com/0VWk0BDJ/36581ebf-d1b2-4e22-8d18-b6b19368c6f3-removebg-preview.png';

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _showPass = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Pendaftaran gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Mendaftarkan akun...',
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF3E6),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        _logoUrl,
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;

                          return const SizedBox(
                            width: 115,
                            height: 115,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _accentOrange,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 115,
                            height: 115,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              color: _accentOrange,
                              size: 52,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Nama Lengkap',
                          hint: 'Masukkan nama lengkap',
                          controller: _nameCtrl,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: _accentOrange,
                          ),
                          validator: (v) =>
                              (v?.isEmpty ?? true)
                                  ? 'Nama wajib diisi'
                                  : null,
                        ),

                        const SizedBox(height: 18),
                                                CustomTextField(
                          label: 'Email',
                          hint: 'contoh@email.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: _accentOrange,
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) {
                              return 'Email wajib diisi';
                            }
                            if (!EmailValidator.validate(v!)) {
                              return 'Format email salah';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        CustomTextField(
                          label: 'Password',
                          hint: 'Minimal 8 karakter',
                          controller: _passCtrl,
                          obscureText: !_showPass,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: _accentOrange,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: _accentOrange,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPass = !_showPass;
                              });
                            },
                          ),
                          validator: (v) {
                            if ((v?.length ?? 0) < 8) {
                              return 'Password minimal 8 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        CustomTextField(
                          label: 'Konfirmasi Password',
                          hint: 'Ulangi password',
                          controller: _pass2Ctrl,
                          obscureText: !_showPass,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: _accentOrange,
                          ),
                          validator: (v) {
                            if (v != _passCtrl.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        CustomButton(
                          label: 'Daftar Sekarang',
                          onPressed: _register,
                          isLoading: isLoading,
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun? ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRouter.login,
                                  );
                                },
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: _accentOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
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