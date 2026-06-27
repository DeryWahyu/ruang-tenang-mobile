import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';

class PremiumPlansScreen extends StatelessWidget {
  const PremiumPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BillingBloc>()..add(const BillingCatalogRequested()),
      child: const _PremiumPlansView(),
    );
  }
}

class _PremiumPlansView extends StatelessWidget {
  const _PremiumPlansView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium & Koin'),
        centerTitle: true,
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state.status == BillingStatus.checkoutSuccess && state.checkoutResult != null) {
            // Note: In real app, this opens Midtrans WebView with checkoutResult['redirect_url']
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Membuka halaman pembayaran...')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BillingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == BillingStatus.failure) {
            return Center(child: Text(state.errorMessage));
          }
          if (state.catalog == null) {
            return const Center(child: Text('Katalog tidak tersedia'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Langganan Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...state.catalog!.plans.map((plan) => _buildPlanCard(context, plan)),
              
              const SizedBox(height: 32),
              
              const Text('Top Up Koin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
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