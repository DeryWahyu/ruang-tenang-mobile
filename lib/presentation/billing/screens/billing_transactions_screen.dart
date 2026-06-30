import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_message.dart';
import '../../../domain/entities/billing.dart';
import '../../../domain/repositories/billing_repository.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_error_widget.dart';
import '../../common/widgets/app_skeleton.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';

/// Layar **Riwayat Pembayaran** — menampilkan daftar transaksi billing
/// (langganan premium & top up koin) dengan paginasi & pull-to-refresh.
/// Selaras dengan halaman billing di web yang menampilkan riwayat transaksi.
class BillingTransactionsScreen extends StatelessWidget {
  const BillingTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BillingBloc>()..add(const BillingTransactionsRequested()),
      child: const _BillingTransactionsView(),
    );
  }
}

class _BillingTransactionsView extends StatefulWidget {
  const _BillingTransactionsView();

  @override
  State<_BillingTransactionsView> createState() => _BillingTransactionsViewState();
}

class _BillingTransactionsViewState extends State<_BillingTransactionsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 240) {
      context.read<BillingBloc>().add(const BillingTransactionsLoadMore());
    }
  }

  /// Ambil CSV dari [fetch], simpan ke file sementara, lalu buka share sheet.
  Future<void> _shareCsv(Future<String> Function() fetch, String filename, String subject) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final csv = await fetch();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')], subject: subject);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(ErrorMessage.from(e, 'Gagal mengekspor data')),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  void _exportAll(BillingState state) {
    _shareCsv(
      () => sl<BillingRepository>().exportTransactionsCsv(
        status: state.filterStatus,
        itemType: state.filterItemType,
      ),
      'riwayat_transaksi.csv',
      'Riwayat Transaksi Ruang Tenang',
    );
  }

  void _downloadInvoice(String orderId) {
    _shareCsv(
      () => sl<BillingRepository>().getInvoiceCsv(orderId),
      'invoice_$orderId.csv',
      'Invoice $orderId',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        actions: [
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              final canExport = state.transactions.isNotEmpty;
              return IconButton(
                icon: const Icon(Icons.download_rounded),
                tooltip: 'Export CSV',
                onPressed: canExport ? () => _exportAll(state) : null,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(),
          Expanded(
            child: BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state.transactionsStatus == TransactionsStatus.loading && state.transactions.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: List.generate(6, (_) => const AppSkeletonListItem()),
                  );
                }
                if (state.transactionsStatus == TransactionsStatus.failure && state.transactions.isEmpty) {
                  return AppErrorWidget(
                    message: state.transactionsError.isNotEmpty
                        ? state.transactionsError
                        : 'Gagal memuat riwayat transaksi',
                    onRetry: () => context.read<BillingBloc>().add(const BillingTransactionsRequested(refresh: true)),
                  );
                }
                if (state.transactions.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'Belum Ada Transaksi',
                    subtitle: 'Pembelian premium dan top up koin akan muncul di sini.',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      context.read<BillingBloc>().add(const BillingTransactionsRequested(refresh: true)),
                  child: ListView.separated(
                    controller: _scrollController,
                    cacheExtent: 600,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.transactions.length + (state.transactionsHasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= state.transactions.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        );
                      }
                      final tx = state.transactions[index];
                      return _TransactionCard(tx: tx, onInvoice: () => _downloadInvoice(tx.orderId));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris filter status & tipe transaksi (chips).
class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      buildWhen: (p, c) => p.filterStatus != c.filterStatus || p.filterItemType != c.filterItemType,
      builder: (context, state) {
        void applyFilter({String? status, String? itemType}) {
          context.read<BillingBloc>().add(
                BillingTransactionsFilterChanged(status: status, itemType: itemType),
              );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _chip(
                label: 'Semua',
                selected: state.filterStatus == null && state.filterItemType == null,
                onTap: () => applyFilter(status: null, itemType: null),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'Premium',
                selected: state.filterItemType == 'subscription',
                onTap: () => applyFilter(
                  status: state.filterStatus,
                  itemType: state.filterItemType == 'subscription' ? null : 'subscription',
                ),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'Top Up',
                selected: state.filterItemType == 'topup',
                onTap: () => applyFilter(
                  status: state.filterStatus,
                  itemType: state.filterItemType == 'topup' ? null : 'topup',
                ),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'Berhasil',
                selected: state.filterStatus == 'paid',
                onTap: () => applyFilter(
                  status: state.filterStatus == 'paid' ? null : 'paid',
                  itemType: state.filterItemType,
                ),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'Menunggu',
                selected: state.filterStatus == 'pending',
                onTap: () => applyFilter(
                  status: state.filterStatus == 'pending' ? null : 'pending',
                  itemType: state.filterItemType,
                ),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'Gagal',
                selected: state.filterStatus == 'failed',
                onTap: () => applyFilter(
                  status: state.filterStatus == 'failed' ? null : 'failed',
                  itemType: state.filterItemType,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.foreground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final BillingTransaction tx;
  final VoidCallback onInvoice;
  const _TransactionCard({required this.tx, required this.onInvoice});

  bool get _isTopup => tx.itemType == 'topup';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (_isTopup ? AppColors.accentOrange : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isTopup ? Icons.monetization_on_rounded : Icons.workspace_premium_rounded,
              color: _isTopup ? AppColors.accentOrange : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.itemName.isNotEmpty ? tx.itemName : (_isTopup ? 'Top Up Koin' : 'Langganan Premium'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFmt.format((tx.paidAt ?? tx.createdAt).toLocal()),
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _StatusChip(status: tx.status),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(tx.amount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: onInvoice,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_rounded, size: 14, color: AppColors.primary),
                      SizedBox(width: 3),
                      Text('Invoice', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip status transaksi dengan warna sesuai keadaan.
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  ({Color color, String label, IconData icon}) get _style {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'settlement':
      case 'success':
      case 'capture':
        return (color: AppColors.success, label: 'Berhasil', icon: Icons.check_circle_rounded);
      case 'pending':
        return (color: AppColors.warning, label: 'Menunggu', icon: Icons.schedule_rounded);
      case 'failed':
      case 'deny':
      case 'cancel':
        return (color: AppColors.destructive, label: 'Gagal', icon: Icons.cancel_rounded);
      case 'expired':
      case 'expire':
        return (color: AppColors.mutedForeground, label: 'Kedaluwarsa', icon: Icons.timer_off_rounded);
      default:
        return (color: AppColors.mutedForeground, label: status, icon: Icons.info_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 13, color: s.color),
          const SizedBox(width: 4),
          Text(s.label, style: TextStyle(color: s.color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
