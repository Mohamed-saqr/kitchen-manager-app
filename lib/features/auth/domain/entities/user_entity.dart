class UserEntity {
  final String uid;
  final String email;
  final String? name;
  final String? department;

  UserEntity({required this.uid, required this.email, this.name, this.department});
}