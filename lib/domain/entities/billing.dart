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

/// Kuota fitur chat AI (limit/used/sisa) — bagian dari status billing.
class ChatQuota extends Equatable {
  final String featureKey;
  final int limit;
  final int used;
  final int remaining;
  final bool isUnlimited;
  final String resetAt;

  const ChatQuota({
    this.featureKey = '',
    this.limit = 0,
    this.used = 0,
    this.remaining = 0,
    this.isUnlimited = false,
    this.resetAt = '',
  });

  @override
  List<Object?> get props => [featureKey, limit, used, remaining, isUnlimited, resetAt];
}

/// Info langganan premium aktif (jika ada).
class SubscriptionInfo extends Equatable {
  final String planName;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  const SubscriptionInfo({
    this.planName = '',
    this.status = '',
    this.startsAt,
    this.endsAt,
  });

  @override
  List<Object?> get props => [planName, status, startsAt, endsAt];
}

/// Status billing pengguna: premium, saldo koin, kuota chat, langganan.
class BillingStatus extends Equatable {
  final bool isPremium;
  final String entitlementSource;
  final DateTime? premiumExpiresAt;
  final int goldCoins;
  final ChatQuota chatQuota;
  final SubscriptionInfo? subscription;

  const BillingStatus({
    this.isPremium = false,
    this.entitlementSource = 'free',
    this.premiumExpiresAt,
    this.goldCoins = 0,
    this.chatQuota = const ChatQuota(),
    this.subscription,
  });

  @override
  List<Object?> get props =>
      [isPremium, entitlementSource, premiumExpiresAt, goldCoins, chatQuota, subscription];
}

/// Satu baris riwayat transaksi pembayaran.
class BillingTransaction extends Equatable {
  final int id;
  final String orderId;
  final String itemType; // subscription | topup
  final String itemName;
  final int amount;
  final String currency;
  final String status; // pending | paid | failed | expired | ...
  final String paymentProvider;
  final String? failureReason;
  final String? snapUrl;
  final DateTime? paidAt;
  final DateTime createdAt;

  const BillingTransaction({
    required this.id,
    required this.orderId,
    required this.itemType,
    required this.itemName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentProvider,
    this.failureReason,
    this.snapUrl,
    this.paidAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, orderId, itemType, itemName, amount, currency, status, paymentProvider, failureReason, snapUrl, paidAt, createdAt];
}

/// Hasil paginasi daftar transaksi.
class BillingTransactionPage extends Equatable {
  final List<BillingTransaction> transactions;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const BillingTransactionPage({
    this.transactions = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.totalPages = 1,
  });

  bool get hasNextPage => page < totalPages;

  @override
  List<Object?> get props => [transactions, total, page, limit, totalPages];
}