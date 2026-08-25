import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/wallet_transaction.dart';

class WalletTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionTile({super.key, required this.transaction});

  Color get _accent {
    if (transaction.isPending) return const Color(0xFFB54708);
    if (transaction.isFailed) return const Color(0xFFB42318);
    if (!transaction.isDebit) return const Color(0xFF067647);

    return switch (transaction.type) {
      WalletTransactionType.reservationFee => AppTheme.primaryBlue,
      WalletTransactionType.parkingFee => const Color(0xFFB54708),
      WalletTransactionType.topUp => const Color(0xFF067647),
      WalletTransactionType.refund => const Color(0xFF067647),
    };
  }

  IconData get _icon {
    return switch (transaction.type) {
      WalletTransactionType.topUp => Icons.add_card_outlined,
      WalletTransactionType.reservationFee => Icons.event_available_outlined,
      WalletTransactionType.parkingFee => Icons.local_parking_outlined,
      WalletTransactionType.refund => Icons.undo_rounded,
    };
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year} · $hour:$minute';
  }

  String get _amountLabel {
    if (transaction.isPending || transaction.isFailed) {
      return 'RM${transaction.amount.toStringAsFixed(2)}';
    }

    final prefix = transaction.isDebit ? '-' : '+';
    return '$prefix RM${transaction.amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 11.8,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(transaction.dateTime),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 10.8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _amountLabel,
            style: TextStyle(
              color: _accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
