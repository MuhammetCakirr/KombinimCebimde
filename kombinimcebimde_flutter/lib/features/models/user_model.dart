class User {
  int id;
  String fname;
  String email;
  String password;
  bool isActive;
  DateTime dateJoined;

  User({
    required this.id,
    required this.fname,
    required this.email,
    required this.password,
    required this.isActive,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fname'],
      email: json['email'],
      password: json['password'],
      isActive: json['is_active'],
      dateJoined: DateTime.parse(json['date_joined']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': fname,
      'email': email,
      'password': password,
      'is_active': isActive,
      'date_joined': dateJoined.toIso8601String(),
    };
  }
}
