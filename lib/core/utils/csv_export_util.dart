import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transport_transaction.dart';

/// CSV Export Utility
/// Generates and shares CSV files for transaction reports
class CSVExportUtil {
  /// Generate CSV from transactions
  static String generateTransactionCSV(List<TransportTransaction> transactions) {
    final buffer = StringBuffer();

    // Header row
    buffer.writeln(
      'Date,Job ID,Route,Distance (km),Earnings (ETB),Status,Payment Method,Paid At',
    );

    // Data rows
    for (final transaction in transactions) {
      buffer.writeln(transaction.toCsvRow());
    }

    return buffer.toString();
  }

  /// Save CSV to file
  static Future<File> saveCSVToFile({
    required String csvContent,
    String? fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'transport_transactions_$timestamp.csv';
      final file = File('${directory.path}/$name');

      await file.writeAsString(csvContent);
      return file;
    } catch (e) {
      throw Exception('Failed to save CSV file: $e');
    }
  }

  /// Export and share CSV
  static Future<void> exportAndShareCSV({
    required List<TransportTransaction> transactions,
    String? fileName,
  }) async {
    try {
      if (transactions.isEmpty) {
        throw Exception('No transactions to export');
      }

      final csvContent = generateTransactionCSV(transactions);
      final file = await saveCSVToFile(
        csvContent: csvContent,
        fileName: fileName,
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Transport Transaction Report',
        text: 'Transaction report for ${transactions.length} deliveries',
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Generate earnings summary CSV
  static String generateEarningsSummaryCSV({
    required double totalEarnings,
    required int totalTrips,
    required double avgEarningsPerTrip,
    required Map<String, double> earningsByMonth,
  }) {
    final buffer = StringBuffer();

    // Summary section
    buffer.writeln('Earnings Summary Report');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('');
    buffer.writeln('Total Earnings,${totalEarnings.toStringAsFixed(2)} ETB');
    buffer.writeln('Total Trips,$totalTrips');
    buffer.writeln('Average per Trip,${avgEarningsPerTrip.toStringAsFixed(2)} ETB');
    buffer.writeln('');

    // Monthly breakdown
    buffer.writeln('Monthly Earnings');
    buffer.writeln('Month,Earnings (ETB)');
    earningsByMonth.forEach((month, earnings) {
      buffer.writeln('$month,${earnings.toStringAsFixed(2)}');
    });

    return buffer.toString();
  }

  /// Format date for CSV
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format currency for CSV
  static String formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Sanitize CSV field (escape commas and quotes)
  static String sanitizeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
