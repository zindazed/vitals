class User {
  final String? user_id;
  final String? username;
  final String? password;

  User(this.user_id, this.username, this.password);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['user_id'],
      json['user_name'],
      json['password'],
    );
  }
}
