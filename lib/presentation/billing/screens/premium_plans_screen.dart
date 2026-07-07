import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/billing.dart';
import '../../common/widgets/app_error_widget.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';

class PremiumPlansScreen extends StatelessWidget {
  const PremiumPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BillingBloc>()
        ..add(const BillingCatalogRequested())
        ..add(const BillingStatusRequested()),
      child: const _PremiumPlansView(),
    );
  }
}

class _PremiumPlansView extends StatelessWidget {
  const _PremiumPlansView();

  /// Membuka halaman pembayaran (Midtrans) dari hasil checkout.
  ///
  /// Backend mengembalikan `redirect_url`; kita buka di browser/aplikasi
  /// eksternal agar pengguna menyelesaikan pembayaran. Tanpa ini, alur
  /// pembayaran menjadi buntu (dead-end).
  Future<void> _openPaymentPage(BuildContext context, Map<String, dynamic> checkoutResult) async {
    // Backend mengembalikan snap_url untuk Midtrans
    final redirectUrl = checkoutResult['snap_url'] as String? ?? checkoutResult['redirect_url'] as String?;
    final messenger = ScaffoldMessenger.of(context);

    if (redirectUrl == null || redirectUrl.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tautan pembayaran tidak tersedia. Coba lagi.')),
      );
      return;
    }

    final uri = Uri.tryParse(redirectUrl);
    final launched = uri != null &&
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);

    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka halaman pembayaran.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium & Koin'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'Riwayat Pembayaran',
            onPressed: () => context.push('/billing/transactions'),
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state.status == BillingStatusEnum.checkoutSuccess && state.checkoutResult != null) {
            _openPaymentPage(context, state.checkoutResult!);
          } else if (state.status == BillingStatusEnum.failure && state.errorMessage.isNotEmpty) {
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
              message: state.errorMessage.isNotEmpty ? state.errorMessage : 'Gagal memuat katalog',
              onRetry: () => context.read<BillingBloc>().add(const BillingCatalogRequested()),
            );
          }
          if (state.catalog == null) {
            return const Center(child: Text('Katalog tidak tersedia'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.billingStatus != null) ...[
                _buildStatusCard(context, state.billingStatus!),
                const SizedBox(height: 24),
              ],
              const Text('Langganan Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...state.catalog!.plans.map((plan) => _buildPlanCard(context, plan)),
              
              const SizedBox(height: 32),
              
              const Text('Top Up Koin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.extent(
                maxCrossAxisExtent: 200,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: state.catalog!.topupPackages.map((pkg) => _buildCoinPackage(context, pkg)).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Kartu ringkasan status: premium/gratis, sisa kuota chat, saldo koin,
  /// plus pintasan ke Riwayat Pembayaran.
  Widget _buildStatusCard(BuildContext context, BillingStatus status) {
    final quota = status.chatQuota;
    final quotaLabel = quota.isUnlimited
        ? 'Tak terbatas'
        : '${quota.remaining}/${quota.limit}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: status.isPremium
              ? [Colors.amber.shade600, Colors.orange.shade700]
              : [AppColors.primary, const Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(status.isPremium ? Icons.workspace_premium_rounded : Icons.person_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(status.isPremium ? 'Akun Premium' : 'Akun Gratis',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statusMetric(Icons.monetization_on_rounded, 'Koin', '${status.goldCoins}'),
              ),
              Expanded(
                child: _statusMetric(Icons.chat_bubble_rounded, 'Kuota Chat', quotaLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => context.push('/billing/transactions'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('Lihat Riwayat Pembayaran'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusMetric(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Rp ${plan.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(plan.description, style: const TextStyle(color: AppColors.mutedForeground)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.read<BillingBloc>().add(BillingCheckoutRequested(itemType: 'subscription', itemId: plan.id)),
                child: const Text('Pilih Paket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPackage(BuildContext context, pkg) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.read<BillingBloc>().add(BillingCheckoutRequested(itemType: 'topup', itemId: pkg.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, size: 48, color: Colors.amber),
              const SizedBox(height: 8),
              Text('${pkg.totalCoins} Koin', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (pkg.bonusCoins > 0)
                Text('+${pkg.bonusCoins} Bonus', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(20)),
                child: Text('Rp ${pkg.price}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}