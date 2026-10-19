import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  /// Export transactions to CSV format
  Future<String> exportToCsv(List<Map<String, dynamic>> transactions) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export');
    }

    // Prepare CSV data
    final List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'Date',
      'Commodity',
      'Quantity',
      'Unit',
      'Amount (ETB)',
      'Buyer/Seller',
      'Status',
    ]);

    // Data rows
    for (final transaction in transactions) {
      rows.add([
        _formatDate(transaction['date']),
        transaction['commodity'] ?? '',
        transaction['quantity'] ?? '',
        transaction['unit'] ?? 'kg',
        _formatAmount(transaction['amount']),
        transaction['party'] ?? transaction['buyer'] ?? transaction['seller'] ?? '',
        transaction['status'] ?? '',
      ]);
    }

    // Convert to CSV string using csv package v8 API
    final csvString = Csv().encoder.convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'agrolink_transactions_${_getDateStamp()}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvString);

    return file.path;
  }

  /// Export transactions and earnings to PDF format
  Future<String> exportToPdf(
    List<Map<String, dynamic>> transactions, {
    String? userName,
  }) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export');
    }

    final pdf = pw.Document();

    // Calculate summary
    final totalTransactions = transactions.length;
    double totalEarnings = 0;
    double totalExpenses = 0;

    for (final transaction in transactions) {
      final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
      final type = transaction['type'] as String? ?? 'Sale';
      
      if (type == 'Sale') {
        totalEarnings += amount;
      } else if (type == 'Purchase') {
        totalExpenses += amount;
      }
    }

    final netEarnings = totalEarnings - totalExpenses;

    // Build PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              'AgroLink Transaction Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // User info
          if (userName != null)
            pw.Text('Generated for: $userName'),
          pw.Text('Generated on: ${_formatDate(DateTime.now())}'),
          pw.SizedBox(height: 20),

          // Summary section
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Transactions:'),
                    pw.Text('$totalTransactions'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Earnings:'),
                    pw.Text('ETB ${_formatAmount(totalEarnings)}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Expenses:'),
                    pw.Text('ETB ${_formatAmount(totalExpenses)}'),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Net Earnings:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'ETB ${_formatAmount(netEarnings)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Transactions table
          pw.Text(
            'Transaction Details',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Commodity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Amount (ETB)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              // Data rows
              ...transactions.map((t) => pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(_formatDate(t['date']), style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(t['commodity'] ?? '', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${t['quantity'] ?? ''} ${t['unit'] ?? 'kg'}', style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(_formatAmount(t['amount']), style: const pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(t['status'] ?? '', style: const pw.TextStyle(fontSize: 9))),
                ],
              )),
            ],
          ),
        ],
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'agrolink_earnings_${_getDateStamp()}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Share exported file
  Future<void> shareFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'AgroLink Export',
    );
  }

  /// Validate date range (max 12 months)
  bool validateDateRange(DateTime start, DateTime end) {
    final difference = end.difference(start);
    return difference.inDays <= 365; // ~12 months
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    
    final DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.parse(date);
    } else {
      return '';
    }

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    final double value = (amount is num) ? amount.toDouble() : 0.0;
    return value.toStringAsFixed(2);
  }

  String _getDateStamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }
}
