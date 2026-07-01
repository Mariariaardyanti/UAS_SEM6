import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';

class SetupOTPPage extends StatefulWidget {
  const SetupOTPPage({super.key});

  @override
  State<SetupOTPPage> createState() => _SetupOTPPageState();
}

class _SetupOTPPageState extends State<SetupOTPPage> {
  bool _loading = true;

  String? _secret;
  String? _qrUrl;

  Timer? _autoRedirectTimer;
  static const int _redirectSeconds = 60;
  int _secondsLeft = _redirectSeconds;

  @override
  void initState() {
    super.initState();
    _loadOTP();
    _startAutoRedirectTimer();
  }

  void _startAutoRedirectTimer() {
    _autoRedirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();
        _selesai(auto: true);
        return;
      }

      setState(() {
        _secondsLeft--;
      });
    });
  }

  Future<void> _loadOTP() async {
    final auth = context.read<AuthProvider>();

    final result = await auth.setupOTP();

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _secret = result["secret"];
        _qrUrl = result["qr_url"];
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil QR Code OTP"),
        ),
      );
    }
  }

  Future<void> _salinKode() async {
    if (_secret == null || _secret!.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: _secret!));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kode disalin, tempel di Google Authenticator"),
      ),
    );
  }

  void _selesai({bool auto = false}) {
    _autoRedirectTimer?.cancel();

    // Tidak ada verifikasi kode di halaman ini.
    // Cukup pop(true) — PaymentPendingPage yang akan otomatis
    // memanggil _launchGlobalInstitutePay() untuk membuka
    // Dompet Kampus Global setelah menerima hasil `true` ini.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          auto
              ? "Waktu habis, lanjut ke Dompet Kampus Global"
              : "OTP berhasil diaktifkan",
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aktivasi OTP"),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Icon(
                    Icons.security,
                    size: 70,
                    color: primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Aktifkan Two Factor Authentication",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Scan QR Code ini menggunakan aplikasi Google Authenticator. "
                    "Setelah tersimpan, aplikasi authenticator akan menampilkan "
                    "kode 6 digit yang nantinya diminta saat kamu melakukan "
                    "pembayaran.",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  Card(
                    color: surface,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: QrImageView(
                        data: _qrUrl ?? "",
                        size: 240,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Tidak bisa scan? Masukkan kode berikut secara manual "
                    "di aplikasi authenticator kamu:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SelectableText(
                            _secret ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _salinKode,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.copy,
                              size: 20,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Otomatis lanjut ke Dompet Kampus Global dalam $_secondsLeft detik",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _selesai(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        "Lanjut Sekarang",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}