import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final bool showAppBar;
  const BillingTransactionsScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<BillingBloc>()..add(const BillingTransactionsRequested()),
      child: _BillingTransactionsView(showAppBar: showAppBar),
    );
  }
}

class _BillingTransactionsView extends StatefulWidget {
  final bool showAppBar;
  const _BillingTransactionsView({required this.showAppBar});

  @override
  State<_BillingTransactionsView> createState() =>
      _BillingTransactionsViewState();
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      context.read<BillingBloc>().add(const BillingTransactionsLoadMore());
    }
  }

  /// Ambil CSV dari [fetch], simpan ke file sementara, lalu buka share sheet.
  Future<void> _shareCsv(
    Future<String> Function() fetch,
    String filename,
    String subject, {
    String errorMessage = 'Gagal mengekspor data',
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final csv = await fetch();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(csv);
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'text/csv'),
      ], subject: subject);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(ErrorMessage.from(e, errorMessage)),
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

  Widget _exportButton() => BlocBuilder<BillingBloc, BillingState>(
    builder: (context, state) {
      final canExport = state.transactions.isNotEmpty;
      return IconButton(
        icon: const Icon(Icons.download_rounded),
        tooltip: 'Ekspor CSV',
        onPressed: canExport ? () => _exportAll(state) : null,
      );
    },
  );

  Future<void> _downloadInvoice(BillingTransaction tx) => _shareCsv(
    () => sl<BillingRepository>().downloadInvoiceCsv(tx.orderId),
    'invoice_${tx.orderId.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')}.csv',
    'Invoice ${tx.orderId}',
    errorMessage: 'Gagal mengunduh invoice',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Riwayat Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
              backgroundColor: AppColors.card,
              surfaceTintColor: Colors.transparent,
              elevation: 1,
              actions: [_exportButton()],
            )
          : null,
      body: Column(
        children: [
          if (!widget.showAppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Riwayat transaksi',
                          style: TextStyle(
                            color: AppColors.foreground,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Pantau pembayaran paket dan koinmu.',
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _exportButton(),
                  ),
                ],
              ),
            ),
          _FilterBar(),
          Expanded(
            child: BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state.transactionsStatus == TransactionsStatus.loading &&
                    state.transactions.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    children: List.generate(
                      6,
                      (_) => const AppSkeletonListItem(),
                    ),
                  );
                }
                if (state.transactionsStatus == TransactionsStatus.failure &&
                    state.transactions.isEmpty) {
                  return AppErrorWidget(
                    message: state.transactionsError.isNotEmpty
                        ? state.transactionsError
                        : 'Gagal memuat riwayat transaksi',
                    onRetry: () => context.read<BillingBloc>().add(
                      const BillingTransactionsRequested(refresh: true),
                    ),
                  );
                }
                if (state.transactions.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => context.read<BillingBloc>().add(
                      const BillingTransactionsRequested(refresh: true),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Container(
                            height:
                                constraints.maxHeight.isFinite &&
                                    constraints.maxHeight > 0
                                ? constraints.maxHeight
                                : 400,
                            alignment: Alignment.center,
                            child: const AppEmptyState(
                              icon: Icons.receipt_long_rounded,
                              title: 'Belum Ada Transaksi',
                              subtitle:
                                  'Pembelian premium dan top up koin akan muncul di sini.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context.read<BillingBloc>().add(
                    const BillingTransactionsRequested(refresh: true),
                  ),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    cacheExtent: 600,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    itemCount:
                        state.transactions.length +
                        (state.transactionsHasMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index >= state.transactions.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final tx = state.transactions[index];
                      return _TransactionCard(
                        tx: tx,
                        onInvoice: () => _downloadInvoice(tx),
                      );
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
      buildWhen: (p, c) =>
          p.filterStatus != c.filterStatus ||
          p.filterItemType != c.filterItemType,
      builder: (context, state) {
        void applyFilter({String? status, String? itemType}) {
          context.read<BillingBloc>().add(
            BillingTransactionsFilterChanged(
              status: status,
              itemType: itemType,
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              _chip(
                label: 'Semua',
                selected:
                    state.filterStatus == null && state.filterItemType == null,
                onTap: () => applyFilter(status: null, itemType: null),
              ),
              const SizedBox(width: 8),
              _chip(
                label: 'Premium',
                selected: state.filterItemType == 'subscription',
                onTap: () => applyFilter(
                  status: state.filterStatus,
                  itemType: state.filterItemType == 'subscription'
                      ? null
                      : 'subscription',
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

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label${selected ? ', dipilih' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.red50 : AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.mutedForeground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
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
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

    final refundColor = tx.refundedAmount > 0
        ? AppColors.success
        : AppColors.warning;
    final canResumePayment =
        tx.status.toLowerCase() == 'pending' &&
        tx.snapUrl != null &&
        tx.snapUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (_isTopup ? const Color(0xFFFFF5D8) : AppColors.red50),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _isTopup
                      ? Icons.toll_rounded
                      : Icons.workspace_premium_rounded,
                  color: _isTopup ? const Color(0xFFD88B00) : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.itemName.isNotEmpty
                          ? tx.itemName
                          : (_isTopup ? 'Top Up Koin' : 'Langganan Premium'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFmt.format((tx.paidAt ?? tx.createdAt).toLocal()),
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: tx.status),
            ],
          ),
          if (tx.refundStatus != 'none') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: refundColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.refundedAmount > 0
                        ? 'Refund terkonfirmasi: ${currency.format(tx.refundedAmount)}'
                        : 'Refund menunggu konfirmasi Midtrans',
                    style: TextStyle(
                      color: refundColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (tx.refundReconciliationStatus == 'pending') ...[
                    const SizedBox(height: 2),
                    const Text(
                      'Sedang ditinjau operator',
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.8)),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: Text(
                  currency.format(tx.amount),
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              if (canResumePayment) ...[
                FilledButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(tx.snapUrl!);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded, size: 15),
                  label: const Text('Bayar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onInvoice,
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Unduh invoice',
                  visualDensity: VisualDensity.compact,
                  color: AppColors.primary,
                ),
              ] else
                TextButton.icon(
                  onPressed: onInvoice,
                  icon: const Icon(Icons.download_rounded, size: 17),
                  label: const Text('Unduh invoice'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
        return (
          color: AppColors.success,
          label: 'Berhasil',
          icon: Icons.check_circle_rounded,
        );
      case 'pending':
        return (
          color: AppColors.warning,
          label: 'Menunggu',
          icon: Icons.schedule_rounded,
        );
      case 'failed':
      case 'deny':
      case 'cancel':
        return (
          color: AppColors.destructive,
          label: 'Gagal',
          icon: Icons.cancel_rounded,
        );
      case 'expired':
      case 'expire':
        return (
          color: AppColors.mutedForeground,
          label: 'Kedaluwarsa',
          icon: Icons.timer_off_rounded,
        );
      default:
        return (
          color: AppColors.mutedForeground,
          label: status,
          icon: Icons.info_outline_rounded,
        );
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
          Text(
            s.label,
            style: TextStyle(
              color: s.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
