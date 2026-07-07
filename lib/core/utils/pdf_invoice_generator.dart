
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../domain/entities/billing.dart';

class PdfInvoiceGenerator {
  static Future<Uint8List> generate(BillingTransaction tx) async {
    final pdf = pw.Document();

    // Load the logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/icon/app_icon.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Fallback if logo fails to load
    }

    // Format dates
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final createdAt = dateFormat.format(tx.createdAt);
    final paidAt = tx.paidAt != null ? dateFormat.format(tx.paidAt!) : '-';

    // Format currency
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null)
                        pw.Image(logoImage, width: 60, height: 60),
                      pw.SizedBox(height: 10),
                      pw.Text('Ruang Tenang', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor(0.8, 0.2, 0.2))),
                      pw.Text('Platform Kesehatan Mental', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                      pw.SizedBox(height: 8),
                      pw.Text('#${tx.orderId}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Transaction Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Informasi Tagihan', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('Tanggal Dibuat: $createdAt', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Tanggal Dibayar: $paidAt', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 4),
                      pw.Text('Metode Pembayaran: ${tx.paymentProvider.toUpperCase()}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Status', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: _getStatusColor(tx.status, isBackground: true),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          tx.status.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: _getStatusColor(tx.status, isBackground: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Items Table
              pw.TableHelper.fromTextArray(
                headers: ['Deskripsi Item', 'Tipe', 'Jumlah'],
                data: [
                  [tx.itemName, tx.itemType.toUpperCase(), currencyFormatter.format(tx.amount)],
                ],
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                  horizontalInside: pw.BorderSide(color: PdfColors.grey300),
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor(0.8, 0.2, 0.2)),
                cellPadding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 20),

              // Total Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Pembayaran: ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 20),
                  pw.Text(currencyFormatter.format(tx.amount), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor(0.8, 0.2, 0.2))),
                ],
              ),

              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Terima kasih telah menggunakan layanan Ruang Tenang.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Jika Anda memiliki pertanyaan, silakan hubungi tim dukungan kami.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static PdfColor _getStatusColor(String status, {required bool isBackground}) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'settlement':
        return isBackground ? const PdfColor(0.9, 0.98, 0.9) : const PdfColor(0.1, 0.6, 0.1);
      case 'pending':
        return isBackground ? const PdfColor(1.0, 0.96, 0.85) : const PdfColor(0.8, 0.6, 0.0);
      case 'failed':
      case 'expire':
      case 'cancel':
        return isBackground ? const PdfColor(1.0, 0.9, 0.9) : const PdfColor(0.8, 0.1, 0.1);
      default:
        return isBackground ? PdfColors.grey200 : PdfColors.grey700;
    }
  }
}
