final class Config {
  Config({required this.email, required this.apiDomain, required this.apiKey});

  final String email;
  final String apiDomain;
  final String apiKey;

  String get emailDomain => email.split('@').last;
}
