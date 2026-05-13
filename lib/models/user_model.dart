class User {
  final String first_name;
  final String last_name;
  final String email;
  final String password;
  final String confirm_password;
  final String phone;

  User({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.password,
    required this.confirm_password,
    required this.phone,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'firstName': first_name,
      'lastName': last_name,
      'email': email,
      'password': password,
      'confirmPassword': confirm_password,
      'phone': phone,
    };
  }
}
