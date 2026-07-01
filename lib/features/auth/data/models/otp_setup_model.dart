class OTPSetupModel {
  final String secret;
  final String qrUrl;

  OTPSetupModel({
    required this.secret,
    required this.qrUrl,
  });

  factory OTPSetupModel.fromJson(Map<String, dynamic> json) {
    return OTPSetupModel(
      secret: json['secret'],
      qrUrl: json['qr_url'],
    );
  }
}