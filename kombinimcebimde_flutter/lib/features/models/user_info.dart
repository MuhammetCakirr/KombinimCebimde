class Muhammet{
  String id;
  String email;
  String phone;
  String sifre;
  String joineddate;
  String fname;

  Muhammet(
  {
    required this.id,
    required this.email,
    required this.phone,
    required this.sifre,
    required this.joineddate,
    required this.fname
  });
  factory Muhammet.fromJson(Map<String, dynamic> json) {
    return Muhammet(
      id: json['id'] ?? 'unknown',
      email: json['email'] ?? 'unknown',
      phone: json['phone'] ?? 'unknown',
      sifre: json['sifre'] ?? 'unknown',
      joineddate: json['joineddate'] ?? 'unknown',
      fname: json['fname'] ?? 'unknown',
    );
  }
}