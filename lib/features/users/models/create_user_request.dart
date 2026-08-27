/// Request model for POST /api/v1/users
class CreateUserRequest {
  final String fullName;
  final String username;
  final String email;
  final String mobile;
  final String password;

  const CreateUserRequest({
    required this.fullName,
    required this.username,
    required this.email,
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'username':  username,
    'email':     email,
    'mobile':    mobile,
    'password':  password,
  };
}
