class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'seller' | 'courier' | 'admin' | 'super-admin'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  bool get isSeller  => role == 'seller';
  bool get isCourier => role == 'courier';
  bool get isAdmin   => role == 'admin' || role == 'super-admin';
}
