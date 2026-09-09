class UserDto {
  final String id;
  final String email;

  const UserDto({required this.id, required this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        email: json['email'] as String,
      );
}
