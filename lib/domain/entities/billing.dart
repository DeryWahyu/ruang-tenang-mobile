import 'package:equatable/equatable.dart';

class PremiumPlan extends Equatable {
  final int id;
  final String code;
  final String name;
  final String description;
  final int price;
  final int durationDays;
  final bool isActive;

  const PremiumPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, code, name, description, price, durationDays, isActive];
}

class TopupPackage extends Equatable {
  final int id;
  final String code;
  final String name;
  final int coins;
  final int bonusCoins;
  final int totalCoins;
  final int price;
  final bool isActive;

  const TopupPackage({
    required this.id,
    required this.code,
    required this.name,
    required this.coins,
    required this.bonusCoins,
    required this.totalCoins,
    required this.price,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, code, name, coins, bonusCoins, totalCoins, price, isActive];
}

class BillingCatalog extends Equatable {
  final List<PremiumPlan> plans;
  final List<TopupPackage> topupPackages;

  const BillingCatalog({
    required this.plans,
    required this.topupPackages,
  });

  @override
  List<Object?> get props => [plans, topupPackages];
}