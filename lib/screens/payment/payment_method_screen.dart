import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  double _topUpAmount = 0;
  bool _argumentLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentLoaded) return;

    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is num) {
      _topUpAmount = argument.toDouble();
    }

    _argumentLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final validAmount = _topUpAmount >= 5;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text(
          'Confirm Top Up',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const Text(
              'Review the amount before updating your ParkUTeM wallet.',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top up amount',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'RM${_topUpAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.primaryBlue,
                    size: 21,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'This top up uses the current ParkUTeM wallet credit flow. '
                      'No external payment gateway is connected to this screen.',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!validAmount) ...[
              const SizedBox(height: 16),
              const Text(
                'Minimum top up amount is RM5.00.',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: validAmount
                  ? () => Navigator.of(context).pop(_topUpAmount)
                  : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Confirm top up'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
