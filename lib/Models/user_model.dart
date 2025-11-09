class User {
  final int id;
  final String email;
  final String role;
  final String name;
  final String? profilePic; // Make profilePic optional

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.profilePic, // Make it optional in constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      name: json['name'],
      profilePic: json['profilePic'], // No need for default value here since it's optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'profilePic': profilePic,
    };
  }

  bool get isCustomer => role.toLowerCase() == 'customer';
  bool get isBarber => role.toLowerCase() == 'barber';
  bool get isOwner => role.toLowerCase() == 'owner';
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Getter for profile picture with guaranteed non-null return
  String get profilePicture {
    return profilePic ?? 'assets/mojies/image10.png';
  }

  // Static method to get current user
  static User getCurrentUser() {
    return User(
      id: 1,
      name: 'John Doe',
      email: 'john.doe@example.com',
      role: 'customer',
      profilePic: 'assets/mojies/image11.png',
    );
  }
}

