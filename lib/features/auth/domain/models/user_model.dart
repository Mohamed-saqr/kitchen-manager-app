class UserModel {
  final String uid;
  final String? email;
  final String? phone;
  final String name;
  final String role;
  final String? department;
  final String? image;

  UserModel({
    required this.uid,
    this.email,
    this.phone,
    required this.name,
    required this.role,
    this.department,
    this.image,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // 👈 هنا بنضمن إن الـ role يتقرأ صح مهما كان شكله في Firestore
    String rawRole = (map['role'] ?? 'chef').toString().toLowerCase().trim();

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      phone: map['phone'] ?? map['phoneNumber'],
      name: map['name'] ?? 'User',
      role: rawRole, // القيمة المتنظفة
      department: map['department'],
      image: map['image'] ?? map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'name': name,
      'role': role,
      'department': department,
      'image': image,
    };
  }
}