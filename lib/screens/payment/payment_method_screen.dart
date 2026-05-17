import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// =====================================================
// PAYMENT METHOD SCREEN
// =====================================================

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

// =====================================================
// PAYMENT METHOD SCREEN STATE
// =====================================================

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  double _topUpAmount = 0.00;
  bool _isArgumentLoaded = false;

  String _selectedMethod = 'Touch n Go eWallet';

  final List<_PaymentMethod> _methods = const [
    _PaymentMethod(
      name: 'Touch n Go eWallet',
      description: 'Pay using TNG eWallet balance',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _PaymentMethod(
      name: 'Online Banking / FPX',
      description: 'Pay using Malaysian online banking',
      icon: Icons.account_balance_rounded,
    ),
    _PaymentMethod(
      name: 'Debit / Credit Card',
      description: 'Pay using Visa or Mastercard',
      icon: Icons.credit_card_rounded,
    ),
    _PaymentMethod(
      name: 'DuitNow QR',
      description: 'Scan and pay using supported banking apps',
      icon: Icons.qr_code_2_rounded,
    ),
  ];

  // =====================================================
  // LOAD ROUTE ARGUMENT
  // =====================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isArgumentLoaded) return;

    final Object? argument = ModalRoute.of(context)?.settings.arguments;

    if (argument is double) {
      _topUpAmount = argument;
    }

    _isArgumentLoaded = true;
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 22),
              _buildAmountCard(),
              const SizedBox(height: 24),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              _buildPaymentNote(),
              const SizedBox(height: 24),
              _buildConfirmButton(),
            ],
          ),
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
          onTap: () => Navigator.of(context).pop(),
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
                'Payment Method',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Choose how you want to top up',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.payments_rounded,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // AMOUNT CARD
  // =====================================================

  Widget _buildAmountCard() {
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
            color: const Color(0xFF0F172A).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Up Amount',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RM${_topUpAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Minimum top up: RM5.00',
              style: TextStyle(
                color: AppTheme.primaryCyan,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PAYMENT METHODS
  // =====================================================

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Payment Method',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Column(
          children: _methods.map((method) {
            final bool isSelected = method.name == _selectedMethod;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PaymentMethodCard(
                method: method,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedMethod = method.name;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // =====================================================
  // PAYMENT NOTE
  // =====================================================

  Widget _buildPaymentNote() {
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
              'This is a prototype payment flow. No real payment will be processed. '
              'The selected amount will be added to your dummy ParkUTeM wallet after confirmation.',
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
  // CONFIRM BUTTON
  // =====================================================

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryCyan,
              AppTheme.primaryBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _confirmPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Confirm Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // CONFIRM PAYMENT
  // =====================================================

  Future<void> _confirmPayment() async {
    if (_topUpAmount < 5) {
      _showMessage('Minimum top up amount is RM5.00.');
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Payment Successful',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'RM${_topUpAmount.toStringAsFixed(2)} has been added to your ParkUTeM Wallet.\n\n'
            'Payment Method: $_selectedMethod',
            style: const TextStyle(
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Done',
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

    if (!mounted) return;

    Navigator.of(context).pop(_topUpAmount);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}

// =====================================================
// PAYMENT METHOD MODEL
// =====================================================

class _PaymentMethod {
  final String name;
  final String description;
  final IconData icon;

  const _PaymentMethod({
    required this.name,
    required this.description,
    required this.icon,
  });
}

// =====================================================
// PAYMENT METHOD CARD
// =====================================================

class _PaymentMethodCard extends StatelessWidget {
  final _PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE8EEF7),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppTheme.primaryBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.74)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}