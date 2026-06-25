import 'package:equatable/equatable.dart';

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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      goldCoins: (json['gold_coins'] as num?)?.toInt() ?? 0,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumUntil: json['premium_until'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      badgeName: json['badge_name'] as String? ?? 'Pemula',
      badgeIcon: json['badge_icon'] as String? ?? '\u{1F331}',
      profileTheme: json['profile_theme'] as String? ?? 'default',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
      'exp': exp,
      'gold_coins': goldCoins,
      'is_premium': isPremium,
      'premium_until': premiumUntil,
      'level': level,
      'badge_name': badgeName,
      'badge_icon': badgeIcon,
      'profile_theme': profileTheme,
      'created_at': createdAt,
    };
  }

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
