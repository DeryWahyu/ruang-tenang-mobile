import 'package:equatable/equatable.dart';
import '../../domain/entities/billing.dart';

class PremiumPlanModel extends Equatable {
  final int id;
  final String code;
  final String name;
  final String description;
  final int price;
  final int durationDays;
  final bool isActive;

  const PremiumPlanModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.isActive,
  });

  factory PremiumPlanModel.fromJson(Map<String, dynamic> json) {
    return PremiumPlanModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  PremiumPlan toEntity() => PremiumPlan(
        id: id,
        code: code,
        name: name,
        description: description,
        price: price,
        durationDays: durationDays,
        isActive: isActive,
      );

  @override
  List<Object?> get props => [id, code, name, description, price, durationDays, isActive];
}

class TopupPackageModel extends Equatable {
  final int id;
  final String code;
  final String name;
  final int coins;
  final int bonusCoins;
  final int totalCoins;
  final int price;
  final bool isActive;

  const TopupPackageModel({
    required this.id,
    required this.code,
    required this.name,
    required this.coins,
    required this.bonusCoins,
    required this.totalCoins,
    required this.price,
    required this.isActive,
  });

  factory TopupPackageModel.fromJson(Map<String, dynamic> json) {
    return TopupPackageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      bonusCoins: (json['bonus_coins'] as num?)?.toInt() ?? 0,
      totalCoins: (json['total_coins'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  TopupPackage toEntity() => TopupPackage(
        id: id,
        code: code,
        name: name,
        coins: coins,
        bonusCoins: bonusCoins,
        totalCoins: totalCoins,
        price: price,
        isActive: isActive,
      );

  @override
  List<Object?> get props => [id, code, name, coins, bonusCoins, totalCoins, price, isActive];
}

class BillingCatalogModel extends Equatable {
  final List<PremiumPlanModel> plans;
  final List<TopupPackageModel> topupPackages;

  const BillingCatalogModel({
    required this.plans,
    required this.topupPackages,
  });

  factory BillingCatalogModel.fromJson(Map<String, dynamic> json) {
    return BillingCatalogModel(
      plans: (json['plans'] as List<dynamic>?)
              ?.map((e) => PremiumPlanModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      topupPackages: (json['topup_packages'] as List<dynamic>?)
              ?.map((e) => TopupPackageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  BillingCatalog toEntity() => BillingCatalog(
        plans: plans.map((e) => e.toEntity()).toList(),
        topupPackages: topupPackages.map((e) => e.toEntity()).toList(),
      );

  @override
  List<Object?> get props => [plans, topupPackages];
}