import 'package:equatable/equatable.dart';
import '../../core/utils/json_parser.dart';
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


// ==========================================
// Billing Status
// ==========================================
class ChatQuotaModel {
  static ChatQuota fromJson(Map<String, dynamic> j) => ChatQuota(
        featureKey: Json.string(j['feature_key']),
        limit: Json.intValue(j['limit']),
        used: Json.intValue(j['used']),
        remaining: Json.intValue(j['remaining']),
        isUnlimited: Json.boolValue(j['is_unlimited']),
        resetAt: Json.string(j['reset_at']),
      );
}

class SubscriptionInfoModel {
  static SubscriptionInfo fromJson(Map<String, dynamic> j) => SubscriptionInfo(
        planName: Json.string(j['plan_name']),
        status: Json.string(j['status']),
        startsAt: Json.date(j['starts_at']),
        endsAt: Json.date(j['ends_at']),
      );
}

class BillingStatusModel {
  static BillingStatus fromJson(Map<String, dynamic> j) => BillingStatus(
        isPremium: Json.boolValue(j['is_premium']),
        entitlementSource: Json.string(j['entitlement_source'], fallback: 'free'),
        premiumExpiresAt: Json.date(j['premium_expires_at']),
        goldCoins: Json.intValue(j['gold_coins']),
        chatQuota: j['chat_quota'] is Map
            ? ChatQuotaModel.fromJson(Map<String, dynamic>.from(j['chat_quota'] as Map))
            : const ChatQuota(),
        subscription: j['subscription'] is Map
            ? SubscriptionInfoModel.fromJson(Map<String, dynamic>.from(j['subscription'] as Map))
            : null,
      );
}

// ==========================================
// Billing Transactions
// ==========================================
class BillingTransactionModel {
  static BillingTransaction fromJson(Map<String, dynamic> j) => BillingTransaction(
        id: Json.intValue(j['id']),
        orderId: Json.string(j['order_id']),
        itemType: Json.string(j['item_type']),
        itemName: Json.string(j['item_name']),
        amount: Json.intValue(j['amount']),
        currency: Json.string(j['currency'], fallback: 'IDR'),
        status: Json.string(j['status']),
        paymentProvider: Json.string(j['payment_provider']),
        failureReason: (j['failure_reason'] as String?)?.isNotEmpty == true
            ? j['failure_reason'] as String
            : null,
        paidAt: Json.date(j['paid_at']),
        createdAt: Json.date(j['created_at']) ?? DateTime.now(),
      );
}

class BillingTransactionPageModel {
  static BillingTransactionPage fromJson(Map<String, dynamic> j) => BillingTransactionPage(
        transactions: Json.list(
          j['transactions'],
          (e) => BillingTransactionModel.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
        total: Json.intValue(j['total']),
        page: Json.intValue(j['page'], fallback: 1),
        limit: Json.intValue(j['limit'], fallback: 20),
        totalPages: Json.intValue(j['total_pages'], fallback: 1),
      );
}
