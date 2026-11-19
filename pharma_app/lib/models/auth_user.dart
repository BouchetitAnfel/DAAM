class AuthUser {
  final int id;
  final String name;
  final String role; // 'pharmacist' | 'client'
  final String token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.role,
    required this.token,
  });

  bool get isPharmacist => role == 'pharmacist';

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: int.parse(j['id'].toString()),
        name: j['name'].toString(),
        role: j['role'].toString(),
        token: j['token'].toString(),
      );
}
