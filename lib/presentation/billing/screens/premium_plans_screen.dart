import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/billing.dart';
import '../../common/widgets/app_error_widget.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';
import '../../common/widgets/mascot_hero.dart';

enum BillingCatalogMode { packages, coins }

class PremiumPlansScreen extends StatelessWidget {
  final BillingCatalogMode mode;
  final bool showAppBar;
  const PremiumPlansScreen({
    super.key,
    this.mode = BillingCatalogMode.packages,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BillingBloc>()
        ..add(const BillingCatalogRequested())
        ..add(const BillingStatusRequested()),
      child: _PremiumPlansView(mode: mode, showAppBar: showAppBar),
    );
  }
}

class _PremiumPlansView extends StatelessWidget {
  final BillingCatalogMode mode;
  final bool showAppBar;
  const _PremiumPlansView({required this.mode, required this.showAppBar});

  static final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Membuka halaman pembayaran Duitku dari hasil checkout.
  ///
  /// Backend mengembalikan `payment_url`; kita buka di browser dalam aplikasi
  /// eksternal agar pengguna menyelesaikan pembayaran. Tanpa ini, alur
  /// pembayaran menjadi buntu (dead-end).
  Future<void> _openPaymentPage(
    BuildContext context,
    Map<String, dynamic> checkoutResult,
  ) async {
    final redirectUrl = checkoutResult['payment_url'] as String?;
    final messenger = ScaffoldMessenger.of(context);

    if (redirectUrl == null || redirectUrl.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tautan pembayaran tidak tersedia. Coba lagi.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(redirectUrl);
    final launched =
        uri != null && await launchUrl(uri, mode: LaunchMode.inAppBrowserView);

    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka halaman pembayaran.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Premium & Koin'),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.receipt_long_rounded),
                  tooltip: 'Riwayat Pembayaran',
                  onPressed: () => context.push('/billing/transactions'),
                ),
              ],
            )
          : null,
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state.status == BillingStatusEnum.checkoutSuccess &&
              state.checkoutResult != null) {
            _openPaymentPage(context, state.checkoutResult!);
          } else if (state.status == BillingStatusEnum.failure &&
              state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BillingStatusEnum.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == BillingStatusEnum.failure) {
            return AppErrorWidget(
              message: state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : 'Gagal memuat katalog',
              onRetry: () => context.read<BillingBloc>().add(
                const BillingCatalogRequested(),
              ),
            );
          }
          if (state.catalog == null) {
            return const Center(child: Text('Katalog tidak tersedia'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BillingBloc>()
                ..add(const BillingCatalogRequested())
                ..add(const BillingStatusRequested());
              // Optional: wait a moment for animation if you don't want to wait for actual state change
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                MascotHero(
                  eyebrow: mode == BillingCatalogMode.packages
                      ? 'PAKET & KOIN'
                      : 'SALDO PERJALANAN',
                  title: mode == BillingCatalogMode.packages
                      ? 'Paket yang menemani'
                      : 'Tambah koin untuk reward',
                  description: mode == BillingCatalogMode.packages
                      ? 'Pilih akses yang sesuai dengan kebutuhanmu.'
                      : 'Tukarkan saldo koin dengan hadiah dan benefit perjalananmu.',
                  pose: mode == BillingCatalogMode.packages
                      ? 'tour-journey'
                      : 'daily-missions',
                  action: mode == BillingCatalogMode.coins
                      ? OutlinedButton.icon(
                          onPressed: () => context.go('/billing?tab=packages'),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          label: const Text('Lihat paket'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        )
                      : null,
                  overflowMascot: true,
                ),
                const SizedBox(height: 18),
                if (state.billingStatus != null) ...[
                  if (mode == BillingCatalogMode.coins)
                    _buildCoinSummaryCards(state.billingStatus!)
                  else
                    _buildStatusCard(
                      context,
                      state.billingStatus!,
                      showQuota: true,
                    ),
                  const SizedBox(height: 22),
                ],
                if (mode == BillingCatalogMode.packages) ...[
                  _sectionHeading(
                    title: 'Pilih paketmu',
                    description: 'Lebih banyak ruang untuk menemani harimu.',
                    icon: Icons.workspace_premium_rounded,
                  ),
                  const SizedBox(height: 12),
                  ...state.catalog!.plans.map(
                    (plan) => _buildPlanCard(context, plan),
                  ),
                ] else ...[
                  _sectionHeading(
                    eyebrow: 'Isi saldo',
                    title: 'Paket top up koin',
                    description: 'Pilih jumlah koin sesuai kebutuhanmu.',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 12),
                  if (state.catalog!.topupPackages.isEmpty)
                    _emptyCoinPackages(context)
                  else
                    _coinPackagesLayout(context, state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeading({
    required String title,
    required String description,
    required IconData icon,
    String? eyebrow,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.red50,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Text(
                  eyebrow.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              if (eyebrow != null) const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoinSummaryCards(BillingStatus status) {
    final quota = status.chatQuota;
    final tier = status.entitlementSource == 'b2b'
        ? 'Premium B2B'
        : status.isPremium
        ? 'Premium'
        : 'Gratis';
    final premiumAccess = status.entitlementSource == 'b2b'
        ? 'Organisasi'
        : status.premiumExpiresAt == null
        ? '-'
        : DateFormat(
            'dd MMM yyyy',
            'id_ID',
          ).format(status.premiumExpiresAt!.toLocal());
    final resetAt = DateTime.tryParse(quota.resetAt);
    final resetLabel = resetAt == null
        ? '-'
        : DateFormat('dd MMM yyyy', 'id_ID').format(resetAt.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _billingMetricCard(
          label: 'Saldo koin',
          value: NumberFormat.decimalPattern('id_ID').format(status.goldCoins),
          detail: 'Bisa dipakai untuk klaim reward',
          asset: 'assets/images/coin.webp',
          isCoin: true,
        ),
        const SizedBox(height: 12),
        _billingMetricCard(
          label: 'Tier aktif',
          value: tier,
          detail: 'Akses: $premiumAccess',
          asset: 'assets/images/mascot/secure.webp',
        ),
        const SizedBox(height: 12),
        _billingMetricCard(
          label: 'Kuota chat',
          value: quota.isUnlimited
              ? 'Tak terbatas'
              : '${quota.remaining} sisa dari ${quota.limit}',
          detail: 'Reset: $resetLabel',
          asset: 'assets/images/mascot/chat-listen.webp',
        ),
      ],
    );
  }

  Widget _billingMetricCard({
    required String label,
    required String value,
    required String detail,
    required String asset,
    bool isCoin = false,
  }) {
    final radius = BorderRadius.circular(18);
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isCoin
                    ? const Color(0xFFFFF5DE)
                    : const Color(0xFFFFF1F2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 78, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: isCoin ? 21 : -8,
            bottom: isCoin ? 21 : -8,
            child: Image.asset(
              asset,
              width: isCoin ? 42 : 76,
              height: isCoin ? 42 : 76,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coinPackagesLayout(BuildContext context, BillingState state) {
    final packages = state.catalog!.topupPackages;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1280
            ? 3
            : constraints.maxWidth >= 768
            ? 2
            : 1;
        final itemWidth = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: packages
              .map(
                (pkg) => SizedBox(
                  width: itemWidth,
                  child: _buildCoinPackage(
                    context,
                    pkg,
                    isSubmitting: state.status == BillingStatusEnum.submitting,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _emptyCoinPackages(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paket top up belum tersedia',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba muat ulang katalog atau lihat pilihan paket Premium.',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.go('/billing?tab=packages'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Lihat paket'),
          ),
        ],
      ),
    );
  }

  /// Ringkasan akun dirancang mengikuti tab yang sedang dibuka.
  Widget _buildStatusCard(
    BuildContext context,
    BillingStatus status, {
    required bool showQuota,
  }) {
    if (!showQuota) return _buildCoinBalanceCard(context, status);

    final quota = status.chatQuota;
    final quotaLabel = quota.isUnlimited
        ? 'Tak terbatas'
        : '${quota.remaining}/${quota.limit}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: showQuota ? AppColors.red100 : const Color(0xFFFDE6B7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: status.isPremium
                      ? const Color(0xFFFFF5D8)
                      : AppColors.red50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  status.isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.person_rounded,
                  color: status.isPremium
                      ? const Color(0xFFD88B00)
                      : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status akun',
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.isPremium ? 'Premium aktif' : 'Akun gratis',
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (status.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5D8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'AKTIF',
                    style: TextStyle(
                      color: Color(0xFF9A6700),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statusMetric(
                  Icons.toll_rounded,
                  'Saldo koin',
                  NumberFormat.decimalPattern('id_ID').format(status.goldCoins),
                  color: const Color(0xFFD88B00),
                  background: const Color(0xFFFFF8E8),
                ),
              ),
              if (showQuota) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _statusMetric(
                    Icons.chat_bubble_outline_rounded,
                    'Kuota chat',
                    quotaLabel,
                    color: AppColors.primary,
                    background: AppColors.red50,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinBalanceCard(BuildContext context, BillingStatus status) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4D7), Color(0xFFFFFCF5), Colors.white],
        ),
        border: Border.all(color: const Color(0xFFF6DFA9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB7791F).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -20,
            child: IgnorePointer(
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5BD4E).withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8A7),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      status.isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.person_rounded,
                      color: const Color(0xFFB7791F),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STATUS AKUN',
                          style: TextStyle(
                            color: Color(0xFF8A6A32),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status.isPremium ? 'Premium aktif' : 'Akun gratis',
                          style: const TextStyle(
                            color: AppColors.foreground,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8A7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'AKTIF',
                        style: TextStyle(
                          color: Color(0xFF8A5A00),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE8A7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.toll_rounded,
                      color: Color(0xFFCC8500),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NumberFormat.decimalPattern(
                            'id_ID',
                          ).format(status.goldCoins),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.foreground,
                            fontSize: 31,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'koin tersedia',
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusMetric(
    IconData icon,
    String label,
    String value, {
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, PremiumPlan plan) {
    final durationLabel = plan.durationDays == 30
        ? '30 hari'
        : plan.durationDays == 90
        ? '90 hari'
        : '${plan.durationDays} hari';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  durationLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            plan.description,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _rupiah.format(plan.price),
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '/ $durationLabel',
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.read<BillingBloc>().add(
                BillingCheckoutRequested(
                  itemType: 'subscription',
                  itemId: plan.id,
                ),
              ),
              icon: const Icon(Icons.lock_open_rounded, size: 18),
              label: const Text('Pilih paket'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackage(
    BuildContext context,
    TopupPackage pkg, {
    required bool isSubmitting,
  }) {
    final numberFormat = NumberFormat.decimalPattern('id_ID');
    final coinBreakdown = pkg.bonusCoins > 0
        ? '${numberFormat.format(pkg.coins)} dasar + ${numberFormat.format(pkg.bonusCoins)} bonus'
        : '${numberFormat.format(pkg.coins)} koin dasar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.code.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pkg.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/coin.webp',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '+${numberFormat.format(pkg.totalCoins)} koin',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            coinBreakdown,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _rupiah.format(pkg.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () => context.read<BillingBloc>().add(
                        BillingCheckoutRequested(
                          itemType: 'topup',
                          itemId: pkg.id,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.muted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Top Up',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
