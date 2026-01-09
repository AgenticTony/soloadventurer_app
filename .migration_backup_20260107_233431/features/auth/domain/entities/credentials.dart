class Credentials {
  final String username;
  final String password;

  const Credentials({
    required this.username,
    required this.password,
  });

  factory Credentials.fromJson(Map<String, dynamic> json) {
    return Credentials(
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}
