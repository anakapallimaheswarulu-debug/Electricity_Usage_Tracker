
import 'package:flutter/material.dart';

import '../models/electricity_reading.dart';
import '../services/database_service.dart';

class UsageHistoryScreen extends StatefulWidget {
  final int userId;

  const UsageHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UsageHistoryScreen> createState() => _UsageHistoryScreenState();
}

class _UsageHistoryScreenState extends State<UsageHistoryScreen> {
  List<ElectricityReading> history = [];
  bool isLoading = true;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF070B14) : const Color(0xFFF4F6FC);

  Color get surface =>
      isDark ? const Color(0xFF101827) : Colors.white;

  Color get surfaceAlt =>
      isDark ? const Color(0xFF182337) : const Color(0xFFE9EEFA);

  Color get textColor =>
      isDark ? const Color(0xFFF5F7FF) : const Color(0xFF17213B);

  Color get mutedColor =>
      isDark ? const Color(0xFF9AA8BD) : const Color(0xFF46536B);

  Color get accentColor =>
      isDark ? const Color(0xFF00B7FF) : const Color(0xFF1769D2);

  Color get purpleColor =>
      isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6741C8);

  Color get borderColor =>
      isDark ? const Color(0x44516D8C) : const Color(0xFFB9C5DA);

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final readings = await DatabaseService.instance.getReadings(
        widget.userId,
      );

      readings.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;

      setState(() {
        history = readings;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('Unable to load usage history.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: surface,
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: mutedColor,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: mutedColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> deleteSingleReading(ElectricityReading item) async {
    final shouldDelete = await _confirmDelete(
      title: 'Delete Reading?',
      message: 'Delete the reading from ${formatDate(item.date)}?',
      confirmText: 'Delete',
    );

    if (!shouldDelete || item.id == null) return;

    try {
      await DatabaseService.instance.deleteReading(item.id!);

      if (!mounted) return;

      setState(() {
        history.remove(item);
      });

      _showMessage('Reading deleted successfully.');
    } catch (_) {
      if (mounted) _showMessage('Unable to delete reading.');
    }
  }

  Future<void> clearAllHistory() async {
    if (history.isEmpty) {
      _showMessage('There is no reading history to delete.');
      return;
    }

    final shouldDelete = await _confirmDelete(
      title: 'Clear All History?',
      message:
          'This will permanently delete all your saved electricity readings. Do you want to continue?',
      confirmText: 'Delete All',
    );

    if (!shouldDelete) return;

    try {
      for (final reading in List<ElectricityReading>.from(history)) {
        if (reading.id != null) {
          await DatabaseService.instance.deleteReading(reading.id!);
        }
      }

      if (!mounted) return;

      setState(() => history.clear());
      _showMessage('All reading history has been deleted.');
    } catch (_) {
      if (mounted) {
        await loadHistory();
        if (mounted) _showMessage('Unable to clear history completely.');
      }
    }
  }

  double get totalUsage => history.fold(
        0.0,
        (total, reading) => total + reading.units,
      );

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      return '${parsedDate.day} '
          '${months[parsedDate.month - 1]} '
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(
          'Usage History',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: clearAllHistory,
            tooltip: 'Clear All History',
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: isDark ? Colors.redAccent : Colors.red.shade700,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: accentColor),
            )
          : RefreshIndicator(
              color: accentColor,
              backgroundColor: surface,
              onRefresh: loadHistory,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: accentColor,
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Previous Readings',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (history.isEmpty)
                    _buildEmptyState()
                  else
                    ...history.map(_historyCard),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF10263B),
                  Color(0xFF151B35),
                  Color(0xFF21153B),
                ]
              : const [
                  Color(0xFFE2EDFF),
                  Color(0xFFEDE6FF),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, purpleColor],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.electric_bolt_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Recorded Usage',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${totalUsage.toStringAsFixed(0)} kWh',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${history.length} reading${history.length == 1 ? '' : 's'} recorded',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.electric_bolt_outlined,
            size: 52,
            color: accentColor,
          ),
          const SizedBox(height: 14),
          Text(
            'No readings yet',
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first meter reading to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(ElectricityReading item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formatDate(item.date),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => deleteSingleReading(item),
                tooltip: 'Delete reading',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: isDark ? Colors.redAccent : Colors.red.shade700,
                ),
              ),
            ],
          ),
          Divider(color: borderColor, height: 24),
          Row(
            children: [
              Expanded(
                child: _readingValue(
                  'Previous',
                  '${item.previousReading.toStringAsFixed(0)} kWh',
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _readingValue(
                  'Current',
                  '${item.currentReading.toStringAsFixed(0)} kWh',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  icon: Icons.bolt_rounded,
                  title: 'Usage',
                  value: '${item.units.toStringAsFixed(0)} kWh',
                  accent: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Bill',
                  value: '₹${item.billAmount.toStringAsFixed(0)}',
                  accent: purpleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readingValue(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: mutedColor, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}