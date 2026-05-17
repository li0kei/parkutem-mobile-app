// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/university_user_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/wallet_service.dart';
import '../../core/services/wallet_transaction_service.dart';
import '../../models/university_user.dart';
import '../../models/wallet_transaction.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/wallet_transaction_tile.dart';


// =====================================================
// WALLET SCREEN
// =====================================================

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

// =====================================================
// WALLET SCREEN STATE
// =====================================================

class _WalletScreenState extends State<WalletScreen> {
  final UniversityUserService _universityUserService = UniversityUserService();
  final WalletService _walletService = WalletService();

  final WalletTransactionService _walletTransactionService =
    WalletTransactionService();

  UniversityUser? _profile;
  late List<WalletTransaction> _transactions;

  bool _isLoading = true;
  String? _errorMessage;

  bool _isTopUpProcessing = false;

  final List<double> _topUpAmounts = const [
    5.00,
    10.00,
    20.00,
    50.00,
  ];

  // =====================================================
  // INIT STATE
  // =====================================================

  @override
  void initState() {
    super.initState();

    _transactions = [];
    _loadWallet();
  }

  // =====================================================
  // LOAD WALLET
  // =====================================================

  Future<void> _loadWallet() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UniversityUser? profile =
          await _universityUserService.getCurrentUserProfile();
      
      final List<WalletTransaction> transactions =
          await _walletTransactionService.getCurrentUserTransactions();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _profile = null;
          _errorMessage = 'Wallet profile was not found.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
      _profile = profile;
      _transactions = transactions;
      _isLoading = false;
    });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _profile = null;
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // HELPERS
  // =====================================================

  double get _walletBalance => _profile?.walletBalance ?? 0.00;

  String get _walletOwnerName => _profile?.fullName ?? 'ParkUTeM User';

  String get _walletOwnerId => _profile?.universityId ?? '-';

  String _formatRM(double amount) {
    return 'RM${amount.toStringAsFixed(2)}';
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadWallet,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        _buildLoadingState()
                      else if (_errorMessage != null)
                        _buildErrorState()
                      else ...[
                        _buildWalletCard(),
                        const SizedBox(height: 24),
                        _buildTopUpSection(),
                        const SizedBox(height: 24),
                        _buildPaymentInfoCard(),
                        const SizedBox(height: 24),
                        _buildTransactionHeader(),
                        const SizedBox(height: 14),
                        _buildTransactionList(),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF0F172A),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage balance and parking payments',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _loadWallet,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LOADING STATE
  // =====================================================

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
          SizedBox(height: 16),
          Text(
            'Loading wallet...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 38,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load wallet',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadWallet,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WALLET CARD
  // =====================================================

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF111D35),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ParkUTeM Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Supabase Balance',
                  style: TextStyle(
                    color: AppTheme.primaryCyan,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            _walletOwnerName,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _walletOwnerId,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _formatRM(_walletBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Available balance for reservation and parking charges',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              _WalletMiniInfo(
                icon: Icons.event_available_rounded,
                label: 'Reservation',
                value: 'RM2 fixed',
              ),
              SizedBox(width: 10),
              _WalletMiniInfo(
                icon: Icons.local_parking_rounded,
                label: 'After 7PM',
                value: 'Hourly fee',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TOP UP SECTION
  // =====================================================

  Widget _buildTopUpSection() {
    return _SectionCard(
      title: 'Quick Top Up',
      child: Column(
        children: [
          Row(
            children: _topUpAmounts.map((amount) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: amount == _topUpAmounts.last ? 0 : 10,
                  ),
                  child: _TopUpAmountCard(
                    amount: amount,
                    onTap: () => _goToPaymentMethod(amount),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _isTopUpProcessing ? null : _showCustomTopUpDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Custom Top Up'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(
                  color: Color(0xFFDCE6F2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PAYMENT INFO CARD
  // =====================================================

  Widget _buildPaymentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryBlue,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reservation fee is charged when students or staff book a bay in advance. '
              'Parking fee is only charged for actual parking usage after 7:00 PM.',
              style: TextStyle(
                color: const Color(0xFF0F172A).withValues(alpha: 0.74),
                fontSize: 12.4,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TRANSACTION HEADER
  // =====================================================

  Widget _buildTransactionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Transaction History',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Text(
          '${_transactions.length} records',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // TRANSACTION LIST
  // =====================================================

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE8EEF7),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF94A3B8),
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _transactions.map((transaction) {
        return WalletTransactionTile(transaction: transaction);
      }).toList(),
    );
  }

  // =====================================================
  // TOP UP WALLET
  // =====================================================

 Future<void> _goToPaymentMethod(double amount) async {
  if (amount < 5) {
    _showMessage('Minimum top up amount is RM5.00.');
    return;
  }

  final Object? result = await Navigator.of(context).pushNamed(
    '/payment-method',
    arguments: amount,
  );

  if (!mounted) return;

  if (result is double) {
    await _processTopUp(result);
  }
}

// =====================================================
// PROCESS TOP UP
// =====================================================

Future<void> _processTopUp(double amount) async {
  if (_isTopUpProcessing) return;

  setState(() {
    _isTopUpProcessing = true;
  });

  try {
    final WalletTopUpResult result = await _walletService.processTopUp(
      amount: amount,
      paymentMethod: 'simulated',
    );

    await _loadWallet();

    if (!mounted) return;

    _showMessage(
      '${_formatRM(amount)} added successfully. Ref: ${result.transactionReference}',
    );
  } catch (error) {
    if (!mounted) return;

    _showMessage('Top up failed: $error');
  } finally {
    if (mounted) {
      setState(() {
        _isTopUpProcessing = false;
      });
    }
  }
}
  // =====================================================
  // CUSTOM TOP UP DIALOG
  // =====================================================

  void _showCustomTopUpDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Custom Top Up',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            cursorColor: AppTheme.primaryBlue,
            decoration: InputDecoration(
              prefixText: 'RM ',
              prefixStyle: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              hintText: 'Minimum RM5.00',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 1.6,
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final double? amount = double.tryParse(
                  controller.text.trim(),
                );

                if (amount == null || amount <= 0) {
                  Navigator.of(dialogContext).pop();
                  _showMessage('Please enter a valid amount.');
                  return;
                }

                if (amount < 5) {
                  Navigator.of(dialogContext).pop();
                  _showMessage('Minimum top up amount is RM5.00.');
                  return;
                }

                Navigator.of(dialogContext).pop();
                _goToPaymentMethod(amount);
              },
              child: const Text(
                'Top Up',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation(BuildContext context) {
    return AppBottomNavigation(
      currentIndex: 3,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        }

        if (index == 1) {
          Navigator.of(context).pushReplacementNamed('/parking');
          return;
        }

        if (index == 2) {
          Navigator.of(context).pushReplacementNamed('/reserve');
          return;
        }

        if (index == 3) return;

        if (index == 4) {
          Navigator.of(context).pushReplacementNamed('/profile');
          return;
        }

        _showMessage('${_navName(index)} screen will be added next.');
      },
    );
  }

  String _navName(int index) {
    switch (index) {
      case 4:
        return 'Profile';
      default:
        return 'Feature';
    }
  }
}

// =====================================================
// SECTION CARD
// =====================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// =====================================================
// WALLET MINI INFO
// =====================================================

class _WalletMiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WalletMiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryCyan,
              size: 20,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TOP UP AMOUNT CARD
// =====================================================

class _TopUpAmountCard extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const _TopUpAmountCard({
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          'RM${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppTheme.primaryBlue,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}