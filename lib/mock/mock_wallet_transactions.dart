import '../models/wallet_transaction.dart';

// =====================================================
// MOCK WALLET TRANSACTIONS
// =====================================================

final List<WalletTransaction> mockWalletTransactions = [
  WalletTransaction(
    id: 'TXN-001',
    title: 'Reservation Fee',
    description: 'Zone A • Bay A12',
    amount: 2.00,
    isDebit: true,
    dateTime: DateTime.now().subtract(const Duration(hours: 2)),
    type: WalletTransactionType.reservationFee,
  ),
  WalletTransaction(
    id: 'TXN-002',
    title: 'Wallet Top Up',
    description: 'Dummy top up successful',
    amount: 20.00,
    isDebit: false,
    dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    type: WalletTransactionType.topUp,
  ),
  WalletTransaction(
    id: 'TXN-003',
    title: 'Parking Fee',
    description: 'After 7PM parking usage',
    amount: 3.00,
    isDebit: true,
    dateTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
    type: WalletTransactionType.parkingFee,
  ),
  WalletTransaction(
    id: 'TXN-004',
    title: 'Reservation Refund',
    description: 'Cancelled reservation refund',
    amount: 2.00,
    isDebit: false,
    dateTime: DateTime.now().subtract(const Duration(days: 4)),
    type: WalletTransactionType.refund,
  ),
];