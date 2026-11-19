/// Modèle Utilisateur, aligné sur la réponse de POST /api/auth/login
/// et /api/auth/register (routes/auth.js) : { id, name, email, role }.
class AppUser {
  final int id;
  final String name;
  final String email;
  final String role; // 'pharmacist' ou 'client'

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isPharmacist => role == 'pharmacist';
  bool get isClient => role == 'client';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
