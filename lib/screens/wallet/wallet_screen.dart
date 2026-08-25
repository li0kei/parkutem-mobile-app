import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/university_user_service.dart';
import '../../core/services/wallet_billplz_service.dart';
import '../../core/services/wallet_transaction_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/university_user.dart';
import '../../models/wallet_transaction.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/wallet_transaction_tile.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver {
  final UniversityUserService _userService = UniversityUserService();
  final WalletTransactionService _transactionService =
      WalletTransactionService();
  final WalletBillplzService _billplzService = WalletBillplzService();

  UniversityUser? _profile;
  List<WalletTransaction> _transactions = [];
  bool _isLoading = true;
  bool _isPaymentBusy = false;
  bool _isCheckingPayment = false;
  String? _error;
  String? _paymentNote;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWallet();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingPayment());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingPayment();
    }
  }

  Future<void> _loadWallet() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait<dynamic>([
        _userService.getCurrentUserProfile(),
        _transactionService.getCurrentUserTransactions(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = results[0] as UniversityUser?;
        _transactions = results[1] as List<WalletTransaction>;
        _isLoading = false;
        if (_profile == null) {
          _error = 'Wallet profile was not found.';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPendingPayment() async {
    if (_isCheckingPayment) {
      return;
    }
    _isCheckingPayment = true;
    try {
      WalletBillplzStatus? status;
      for (int attempt = 0; attempt < 4; attempt += 1) {
        status = await _billplzService.resolvePendingTopUp();
        if (status == null) {
          return;
        }
        if (status.state != WalletBillplzState.pending) {
          break;
        }
        if (attempt < 3) {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
        }
      }

      if (!mounted || status == null) {
        return;
      }

      switch (status.state) {
        case WalletBillplzState.paid:
          setState(
            () => _paymentNote =
                'Payment verified. Your wallet has been updated.',
          );
          await _loadWallet();
          break;
        case WalletBillplzState.failed:
          setState(() => _paymentNote = 'Billplz payment was not completed.');
          break;
        case WalletBillplzState.expired:
          setState(() => _paymentNote = 'The Billplz payment session expired.');
          break;
        case WalletBillplzState.pending:
          setState(
            () => _paymentNote =
                'Payment is still waiting for verified Billplz confirmation.',
          );
          break;
      }
    } catch (error) {
      if (mounted) {
        setState(
          () =>
              _paymentNote = 'Payment verification is temporarily unavailable.',
        );
      }
    } finally {
      _isCheckingPayment = false;
    }
  }

  double get _balance => _profile?.walletBalance ?? 0;

  void _navigateFromBottomBar(int index) {
    final routes = ['/home', '/parking', '/reserve', '/wallet', '/profile'];
    if (index == 3) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadWallet,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 110),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _buildError()
                    else ...[
                      const Text(
                        'Available balance',
                        style: TextStyle(color: AppTheme.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'RM${_balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isPaymentBusy ? null : _showTopUpPicker,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Top up with Billplz'),
                        ),
                      ),
                      if (_paymentNote != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.primaryBlue,
                              size: 19,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                _paymentNote!,
                                style: const TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            if (_paymentNote!.contains('waiting'))
                              TextButton(
                                onPressed: _checkPendingPayment,
                                child: const Text('Check'),
                              ),
                          ],
                        ),
                      ],
                      const Divider(height: 40),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Transactions',
                              style: TextStyle(
                                color: AppTheme.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${_transactions.length}',
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTransactions(),
                    ],
                  ],
                ),
              ),
            ),
            AppBottomNavigation(currentIndex: 3, onTap: _navigateFromBottomBar),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions() {
    if (_transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 38),
        child: Center(
          child: Text(
            'No transactions yet.',
            style: TextStyle(color: AppTheme.muted),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (int index = 0; index < _transactions.length; index++) ...[
          WalletTransactionTile(transaction: _transactions[index]),
          if (index != _transactions.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }

  Widget _buildError() => Column(
    children: [
      const SizedBox(height: 80),
      const Icon(Icons.cloud_off_outlined, color: AppTheme.muted, size: 34),
      const SizedBox(height: 10),
      const Text(
        'Unable to load wallet.',
        style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 14),
      OutlinedButton(onPressed: _loadWallet, child: const Text('Try again')),
    ],
  );

  Future<void> _showTopUpPicker() async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => const _TopUpPickerSheet(),
    );
    if (amount == null || !mounted) {
      return;
    }

    final confirmed = await Navigator.of(
      context,
    ).pushNamed('/payment-method', arguments: amount);
    if (confirmed is double && mounted) {
      await _startBillplzTopUp(confirmed);
    }
  }

  Future<void> _startBillplzTopUp(double amount) async {
    if (_isPaymentBusy) {
      return;
    }
    setState(() {
      _isPaymentBusy = true;
      _paymentNote = null;
    });
    try {
      final checkout = await _billplzService.createTopUp(amount);
      final uri = Uri.tryParse(checkout.paymentUrl);
      if (uri == null) {
        throw Exception('Invalid Billplz payment URL.');
      }

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        throw Exception('Unable to open Billplz.');
      }

      if (mounted) {
        setState(
          () => _paymentNote =
              'Complete the payment in Billplz, then return to ParkUTeM.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to start Billplz payment: $error', error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isPaymentBusy = false);
      }
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB42318) : AppTheme.ink,
      ),
    );
  }
}

class _TopUpPickerSheet extends StatefulWidget {
  const _TopUpPickerSheet();
  @override
  State<_TopUpPickerSheet> createState() => _TopUpPickerSheetState();
}

class _TopUpPickerSheetState extends State<_TopUpPickerSheet> {
  double _amount = 10;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top up wallet',
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Payment is completed securely on Billplz.',
            style: TextStyle(color: AppTheme.muted, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          for (final value in const [5.0, 10.0, 20.0, 50.0])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('RM${value.toStringAsFixed(0)}'),
              trailing: Icon(
                _amount == value
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: _amount == value ? AppTheme.primaryBlue : AppTheme.muted,
              ),
              onTap: () {
                setState(() {
                  _amount = value;
                  _controller.clear();
                });
              },
            ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Other amount',
              prefixText: 'RM ',
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value.trim());
              if (parsed != null) {
                setState(() => _amount = parsed);
              }
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _amount >= 5 && _amount <= 500
                  ? () => Navigator.of(context).pop(_amount)
                  : null,
              child: Text('Continue · RM${_amount.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Minimum RM5 · Maximum RM500',
            style: TextStyle(color: AppTheme.muted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
