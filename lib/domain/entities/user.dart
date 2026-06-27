import 'package:equatable/equatable.dart';

/// Pure-Dart user entity (domain layer).
///
/// No JSON coupling (fromJson/toJson live in [UserModel] at the data
/// layer). Field names and getters are kept identical to the legacy
/// model so presentation widgets need no field-access changes.
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String avatar;
  final String role;
  final int exp;
  final int goldCoins;
  final bool isPremium;
  final String? premiumUntil;
  final int level;
  final String badgeName;
  final String badgeIcon;
  final String profileTheme;
  final String? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar = '',
    this.role = 'user',
    this.exp = 0,
    this.goldCoins = 0,
    this.isPremium = false,
    this.premiumUntil,
    this.level = 1,
    this.badgeName = 'Pemula',
    this.badgeIcon = '\u{1F331}',
    this.profileTheme = 'default',
    this.createdAt,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    String? role,
    int? exp,
    int? goldCoins,
    bool? isPremium,
    String? premiumUntil,
    int? level,
    String? badgeName,
    String? badgeIcon,
    String? profileTheme,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      exp: exp ?? this.exp,
      goldCoins: goldCoins ?? this.goldCoins,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      level: level ?? this.level,
      badgeName: badgeName ?? this.badgeName,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      profileTheme: profileTheme ?? this.profileTheme,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isMitra => role == 'mitra';
  bool get isUser => role == 'user';

  @override
  List<Object?> get props => [id, name, email, role, exp, goldCoins, isPremium, level];
}
