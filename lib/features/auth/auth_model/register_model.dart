class RegisterModel {
  String name;
  String password;
  String email;
  String phone;

  RegisterModel({
    this.name = '',
    this.password = '',
    this.email = '',
    this.phone = '',
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    name: json['name'],
    password: json['password'],
    email: json['email'],
    phone: json['phone'],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "password": password,
    "email": email,
    "phone": phone,
  };
}

