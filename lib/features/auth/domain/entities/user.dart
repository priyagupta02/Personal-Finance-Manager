import 'package:equatable/equatable.dart';

/// A signed-in user. Pure domain object — no serialization or storage concerns.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}
