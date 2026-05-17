// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/vehicle_service.dart';
import '../../core/theme/app_theme.dart';

// =====================================================
// VEHICLE REGISTRATION SCREEN
// =====================================================

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

// =====================================================
// VEHICLE REGISTRATION SCREEN STATE
// =====================================================

class _VehicleRegistrationScreenState
    extends State<VehicleRegistrationScreen> {
  final VehicleService _vehicleService = VehicleService();

  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  bool _isSubmitting = false;

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  // =====================================================
  // SUBMIT VEHICLE
  // =====================================================

  Future<void> _submitVehicle() async {
    final String plateNumber = _plateController.text.trim();
    final String vehicleModel = _modelController.text.trim();
    final String vehicleColor = _colorController.text.trim();

    if (plateNumber.isEmpty) {
      _showMessage('Please enter your vehicle plate number.', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _vehicleService.registerCurrentUserVehicle(
        plateNumber: plateNumber,
        vehicleModel: vehicleModel,
        vehicleColor: vehicleColor,
      );

      if (!mounted) return;

      _showMessage('Vehicle registration submitted for admin review.');

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Registration failed: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF0F172A),
      ),
    );
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
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildFormCard(),
              const SizedBox(height: 18),
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
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
          onTap: _isSubmitting ? null : () => Navigator.of(context).pop(),
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
                'Register Vehicle',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Submit sticker and ANPR access request',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // FORM CARD
  // =====================================================

  Widget _buildFormCard() {
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
          const Text(
            'Vehicle Details',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          _VehicleInputField(
            controller: _plateController,
            label: 'Plate Number',
            hintText: 'Example: BKP 410',
            icon: Icons.pin_rounded,
            enabled: !_isSubmitting,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 14),
          _VehicleInputField(
            controller: _modelController,
            label: 'Vehicle Model',
            hintText: 'Example: Toyota Vios',
            icon: Icons.directions_car_filled_rounded,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 14),
          _VehicleInputField(
            controller: _colorController,
            label: 'Vehicle Color',
            hintText: 'Example: White',
            icon: Icons.palette_rounded,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitVehicle(),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // INFO CARD
  // =====================================================

  Widget _buildInfoCard() {
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
              'Your vehicle will be submitted as pending. Admin must approve '
              'the sticker before ANPR access can be enabled.',
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
  // SUBMIT BUTTON
  // =====================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitVehicle,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(_isSubmitting ? 'Submitting...' : 'Submit Registration'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF94A3B8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// VEHICLE INPUT FIELD
// =====================================================

class _VehicleInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;

  const _VehicleInputField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
      ),
      cursorColor: AppTheme.primaryBlue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        labelStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: AppTheme.primaryBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}