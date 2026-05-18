// models/user_model.dart
class UserModel {
  final String first_name;
  final String last_name;
  final String email;
  final String password;
  final String confirm_password;
  final String phone;

  UserModel({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.password,
    required this.confirm_password,
    required this.phone,
  });

  // From JSON (for profile responses - no password fields)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      first_name: json['first_name'] ?? json['firstName'] ?? '',
      last_name: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: '', // Don't store password from profile
      confirm_password: '',
      phone: json['phone'] ?? '',
    );
  }

  // To JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'password': password,
      'confirm_password': confirm_password,
      'phone': phone,
    };
  }

  // Profile-only version (without password)
  Map<String, dynamic> toProfileJson() {
    return {
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'phone': phone,
    };
  }
}