import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionEntry transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final isCredit = tx.direction == 'CREDIT';
    final amount = tx.amountCent / 100;
    final isSynced = tx.syncStatus == 'SYNCED';
    final isPending = tx.syncStatus == 'PENDING';
    final isFailed = tx.syncStatus == 'FAILED';

    // Info transaksi
    String txTitle;
    IconData txIcon;
    if (tx.txType == 'TOPUP') {
      txTitle = 'Top Up Saldo';
      txIcon = Icons.account_balance_wallet_rounded;
    } else if (tx.txType == 'TRANSFER') {
      txTitle = isCredit ? 'Terima Saldo' : 'Kirim Saldo';
      txIcon = isCredit ? Icons.call_received_rounded : Icons.send_rounded;
    } else {
      txTitle = 'Transaksi';
      txIcon = Icons.swap_horiz_rounded;
    }

    // Warna status
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    if (isSynced) {
      statusColor = context.colors.success;
      statusLabel = 'Berhasil Tersinkron';
      statusIcon = Icons.check_circle_rounded;
    } else if (isFailed) {
      statusColor = context.colors.error;
      statusLabel = 'Gagal Sinkronisasi';
      statusIcon = Icons.error_rounded;
    } else {
      statusColor = context.colors.warning;
      statusLabel = 'Menunggu Sinkronisasi';
      statusIcon = Icons.schedule_rounded;
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(context, txTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            // Header sukses / status
            _buildStatusHeader(context, isCredit, amount, statusColor, statusLabel, statusIcon, txIcon),
            const SizedBox(height: 20),

            // Detail transaksi
            _buildDetailCard(context, tx, isCredit, amount, txTitle),
            const SizedBox(height: 16),

            // Info sinkronisasi
            _buildSyncCard(context, tx, statusColor, statusLabel, statusIcon),
            const SizedBox(height: 16),

            // Info teknis
            _buildTechCard(context, tx),
            const SizedBox(height: 24),

            // Tombol aksi
            _buildActionButtons(context, tx, isFailed),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          Image.asset('assets/icons/icon.png', height: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Header ───

  Widget _buildStatusHeader(
    BuildContext context,
    bool isCredit,
    double amount,
    Color statusColor,
    String statusLabel,
    IconData statusIcon,
    IconData txIcon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Ikon besar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 36),
          ),
          const SizedBox(height: 16),

          // Nominal
          Text(
            '${isCredit ? '+' : '-'}Rp ${_formatAmount(amount)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isCredit ? context.colors.success : context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Detail Card ───

  Widget _buildDetailCard(
    BuildContext context,
    TransactionEntry tx,
    bool isCredit,
    double amount,
    String txTitle,
  ) {
    final counterparty = tx.counterpartyName ?? '-';
    final counterpartyLabel = isCredit ? 'Dari' : 'Kepada';

    return _sectionCard(
      context: context,
      title: 'DETAIL TRANSAKSI',
      children: [
        _detailRow(context, 'Jenis Transaksi', txTitle),
        _detailRow(context, 'Arah', isCredit ? 'Masuk (Credit)' : 'Keluar (Debit)'),
        _detailRow(context, counterpartyLabel, counterparty),
        _detailRow(context, 'Nominal', 'Rp ${_formatAmount(amount)}'),
        _detailRow(context, 'Hop Count', '${tx.hopCount}'),
        _detailRow(context, 'Tanggal', _formatFullDate(tx.createdAt)),
        _detailRow(context, 'Waktu', _formatTime(tx.createdAt), isLast: true),
      ],
    );
  }

  // ─── Sync Card ───

  Widget _buildSyncCard(
    BuildContext context,
    TransactionEntry tx,
    Color statusColor,
    String statusLabel,
    IconData statusIcon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUS SINKRONISASI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 14),

          // Status bar
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSyncDescription(tx.syncStatus),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Progress bar sync
          if (tx.syncStatus == 'PENDING') ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: null,
                minHeight: 6,
                backgroundColor: context.colors.border,
                color: context.colors.warning,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Akan otomatis tersinkron saat online',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Tech Card ───

  Widget _buildTechCard(BuildContext context, TransactionEntry tx) {
    return _sectionCard(
      context: context,
      title: 'INFO TEKNIS',
      children: [
        _detailRow(context, 'Transaction ID', tx.txId),
        _detailRow(context, 'Tipe', tx.txType),
        _detailRow(context, 'Direction', tx.direction),
        _detailRow(context, 'Hop Count', '${tx.hopCount}'),
        _detailRow(context, 'Counterparty', tx.counterpartyName ?? '-'),
        _detailRow(context, 'Sync Status', tx.syncStatus),
        _detailRow(context, 'Dibuat', _formatFullDate(tx.createdAt), isLast: true),
      ],
    );
  }

  // ─── Action Buttons ───

  Widget _buildActionButtons(BuildContext context, TransactionEntry tx, bool isFailed) {
    final isCredit = tx.direction == 'CREDIT';
    final amount = tx.amountCent / 100;
    String txTitle;
    if (tx.txType == 'TOPUP') {
      txTitle = 'Top Up Saldo';
    } else if (tx.txType == 'TRANSFER') {
      txTitle = isCredit ? 'Terima Saldo' : 'Kirim Saldo';
    } else {
      txTitle = 'Transaksi';
    }
    String statusLabel = tx.syncStatus == 'SYNCED' ? 'Berhasil' : (isFailed ? 'Gagal' : 'Pending');

    return Column(
      children: [
        // Tombol bagikan PDF
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _generateAndSharePdf(context, tx, isCredit, amount, txTitle, statusLabel),
            icon: Icon(Icons.share_rounded, size: 18),
            label: Text('Bagikan Bukti (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tombol salin TX ID
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tx.txId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction ID disalin'),
                  backgroundColor: context.colors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.copy_rounded, size: 18),
            label: Text('Salin Transaction ID'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.textPrimary,
              side: BorderSide(color: context.colors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Tombol retry jika gagal
        if (isFailed) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement retry sync
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fitur retry belum tersedia'),
                    backgroundColor: context.colors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: Icon(Icons.refresh_rounded, size: 18),
              label: Text('Coba Sinkronisasi Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Helpers ───

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSyncDescription(String status) {
    switch (status) {
      case 'SYNCED':
        return 'Transaksi sudah terverifikasi oleh server';
      case 'PENDING':
        return 'Menunggu koneksi internet untuk sinkronisasi';
      case 'FAILED':
        return 'Gagal sinkronisasi. Coba lagi saat online.';
      default:
        return 'Status tidak diketahui';
    }
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return NumberFormat('#,###').format(amount.toInt());
    }
    return NumberFormat('#,###.##').format(amount);
  }

  String _formatFullDate(DateTime dt) {
    return DateFormat('d MMMM yyyy').format(dt);
  }

  String _formatTime(DateTime dt) {
    return DateFormat('HH:mm:ss').format(dt);
  }

  // ─── PDF Generator ───

  Future<void> _generateAndSharePdf(
    BuildContext context,
    TransactionEntry tx,
    bool isCredit,
    double amount,
    String txTitle,
    String statusLabel,
  ) async {
    try {
      // Tampilkan indikator loading di UI (opsional, karena proses cukup cepat)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menyiapkan bukti transaksi...'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Load logo dari asset
      final ByteData bytes = await rootBundle.load('assets/icons/icon.png');
      final Uint8List logoData = bytes.buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoData);

      final pdf = pw.Document();
      final primaryColor = PdfColor.fromHex('#009CFF');
      final successColor = PdfColor.fromHex('#26644A');
      final textPrimary = PdfColor.fromHex('#1E1E24');
      final textSecondary = PdfColor.fromHex('#6B7280');
      final borderColor = PdfColor.fromHex('#E2E6EE');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header dengan logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, height: 40),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'NirPay',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'BUKTI TRANSAKSI',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                    color: textPrimary,
                  ),
                ),
                pw.SizedBox(height: 32),

                // Kotak Jumlah dan Status
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 24),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F4F7FB'),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '${isCredit ? '+' : '-'}Rp ${_formatAmount(amount)}',
                        style: pw.TextStyle(
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          color: isCredit ? successColor : textPrimary,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        statusLabel,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: tx.syncStatus == 'SYNCED'
                              ? successColor
                              : (tx.syncStatus == 'FAILED' ? PdfColor.fromHex('#D63C42') : PdfColor.fromHex('#FF9500')),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                // Detail Transaksi
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DETAIL TRANSAKSI',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 16),
                      _buildPdfDetailRow('Jenis Transaksi', txTitle, textSecondary, textPrimary),
                      _buildPdfDetailRow('Arah', isCredit ? 'Masuk (Credit)' : 'Keluar (Debit)', textSecondary, textPrimary),
                      _buildPdfDetailRow(isCredit ? 'Dari' : 'Kepada', tx.counterpartyName ?? '-', textSecondary, textPrimary),
                      _buildPdfDetailRow('Nominal', 'Rp ${_formatAmount(amount)}', textSecondary, textPrimary),
                      _buildPdfDetailRow('Hop Count', '${tx.hopCount}', textSecondary, textPrimary),
                      _buildPdfDetailRow('Tanggal', _formatFullDate(tx.createdAt), textSecondary, textPrimary),
                      _buildPdfDetailRow('Waktu', _formatTime(tx.createdAt), textSecondary, textPrimary),
                      _buildPdfDetailRow('Transaction ID', tx.txId, textSecondary, textPrimary, isLast: true),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer Informasi NirPay
                pw.Divider(color: borderColor),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Bukti transaksi ini diterbitkan oleh sistem NirPay sebagai dokumen yang sah. '
                  'NirPay tidak berafiliasi dengan pihak pengiklan atau pihak ketiga lainnya kecuali dinyatakan sebaliknya.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromHex('#8A93A2'), // Lighter text for footer
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Simpan PDF ke temporary directory
      final Uint8List pdfBytes = await pdf.save();
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/Bukti_Transaksi_${tx.txId}.pdf';
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Bagikan menggunakan share_plus
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Bukti Transaksi NirPay - ${tx.txId}',
        text: 'Berikut adalah bukti transaksi Anda dari NirPay.',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat PDF: $e'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  pw.Widget _buildPdfDetailRow(String label, String value, PdfColor labelColor, PdfColor valueColor, {bool isLast = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(color: labelColor, fontSize: 13),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: valueColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
