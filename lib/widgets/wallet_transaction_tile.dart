import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/wallet_transaction.dart';

// =====================================================
// WALLET TRANSACTION TILE
// =====================================================

class WalletTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionTile({
    super.key,
    required this.transaction,
  });

  // =====================================================
  // TRANSACTION COLOR
  // =====================================================

  Color get transactionColor {
    if (!transaction.isDebit) return const Color(0xFF22C55E);

    switch (transaction.type) {
      case WalletTransactionType.reservationFee:
        return AppTheme.primaryBlue;
      case WalletTransactionType.parkingFee:
        return const Color(0xFFF59E0B);
      case WalletTransactionType.topUp:
        return const Color(0xFF22C55E);
      case WalletTransactionType.refund:
        return const Color(0xFF22C55E);
    }
  }

  // =====================================================
  // TRANSACTION ICON
  // =====================================================

  IconData get transactionIcon {
    switch (transaction.type) {
      case WalletTransactionType.topUp:
        return Icons.add_card_rounded;
      case WalletTransactionType.reservationFee:
        return Icons.event_available_rounded;
      case WalletTransactionType.parkingFee:
        return Icons.local_parking_rounded;
      case WalletTransactionType.refund:
        return Icons.undo_rounded;
    }
  }

  // =====================================================
  // DATE FORMATTER
  // =====================================================

  String _formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year} • $hour:$minute';
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final String prefix = transaction.isDebit ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: transactionColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              transactionIcon,
              color: transactionColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.dateTime),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$prefix RM${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: transaction.isDebit
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF22C55E),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}