class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.empresaId,
    required this.empresaNombre,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final int empresaId;
  final String empresaNombre;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: (json['accessToken'] ?? '').toString(),
      tokenType: (json['tokenType'] ?? 'bearer').toString(),
      expiresIn: _asInt(json['expiresIn']),
      empresaId: _asInt(json['empresaId']),
      empresaNombre: (json['empresaNombre'] ?? '').toString(),
    );
  }

  static int _asInt(dynamic value) => int.tryParse('$value') ?? 0;
}
