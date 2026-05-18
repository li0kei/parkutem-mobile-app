// =====================================================
// IMPORTS
// =====================================================

import 'package:flutter/material.dart';

import '../../core/services/support_issue_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/support_issue_result.dart';

// =====================================================
// HELP SUPPORT SCREEN
// =====================================================

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

// =====================================================
// HELP SUPPORT SCREEN STATE
// =====================================================

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final SupportIssueService _supportIssueService = SupportIssueService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _bayController = TextEditingController();
  final TextEditingController _bookingReferenceController =
      TextEditingController();

  String _selectedIssueType = 'general';
  String _selectedPriority = 'medium';

  bool _isSubmitting = false;

  final List<_IssueOption> _issueTypes = const [
    _IssueOption(value: 'general', label: 'General'),
    _IssueOption(value: 'payment', label: 'Payment'),
    _IssueOption(value: 'anpr', label: 'ANPR Detection'),
    _IssueOption(value: 'reservation', label: 'Reservation'),
    _IssueOption(value: 'sticker', label: 'Sticker / Vehicle'),
    _IssueOption(value: 'parking_bay', label: 'Parking Bay'),
  ];

  final List<_IssueOption> _priorities = const [
    _IssueOption(value: 'low', label: 'Low'),
    _IssueOption(value: 'medium', label: 'Medium'),
    _IssueOption(value: 'high', label: 'High'),
    _IssueOption(value: 'critical', label: 'Critical'),
  ];

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _plateController.dispose();
    _bayController.dispose();
    _bookingReferenceController.dispose();
    super.dispose();
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
              const SizedBox(height: 24),
              _buildContactCard(),
              const SizedBox(height: 24),
              _buildReportIssueCard(),
              const SizedBox(height: 24),
              _buildFaqCard(),
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
        _BackButton(onTap: () => Navigator.of(context).pop()),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help & Support',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Submit issues to parking administrator',
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
  // CONTACT CARD
  // =====================================================

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF056BF1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(height: 16),
          Text(
            'Parking Administration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'For sticker issues, reservation problems, payment concerns, parking bay problems, or ANPR detection errors.',
            style: TextStyle(
              color: Color(0xFFDCEBFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // REPORT ISSUE CARD
  // =====================================================

  Widget _buildReportIssueCard() {
    return _SectionCard(
      title: 'Report an Issue',
      child: Column(
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Issue Title',
            hintText: 'Example: ANPR detected wrong plate',
            icon: Icons.title_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Issue Type',
                  value: _selectedIssueType,
                  options: _issueTypes,
                  icon: Icons.category_rounded,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedIssueType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Priority',
                  value: _selectedPriority,
                  options: _priorities,
                  icon: Icons.priority_high_rounded,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedPriority = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: 'Describe what happened...',
            icon: Icons.description_rounded,
            maxLines: 5,
          ),
          const SizedBox(height: 18),
          _buildOptionalFields(),
          const SizedBox(height: 18),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // =====================================================
  // OPTIONAL FIELDS
  // =====================================================

  Widget _buildOptionalFields() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EEF7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optional Related Details',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Fill these only if the issue is related to a vehicle, bay, or reservation.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _plateController,
            label: 'Related Plate',
            hintText: 'Example: ABC1122',
            icon: Icons.directions_car_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bayController,
            label: 'Related Bay',
            hintText: 'Example: A-02',
            icon: Icons.local_parking_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bookingReferenceController,
            label: 'Reservation / Booking Reference',
            hintText: 'Example: RSV-20260517...',
            icon: Icons.confirmation_number_rounded,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FAQ CARD
  // =====================================================

  Widget _buildFaqCard() {
    return _SectionCard(
      title: 'Frequently Asked Questions',
      child: const Column(
        children: [
          _FaqTile(
            question: 'Why do I need to pay reservation fee?',
            answer:
                'Reservation fee is a fixed one-time fee for booking a parking bay in advance.',
          ),
          _FaqTile(
            question: 'Is student/staff parking free?',
            answer:
                'Normal student/staff parking is free from 7:00 AM to 7:00 PM without reservation.',
          ),
          _FaqTile(
            question: 'When is parking fee charged?',
            answer:
                'Parking fee is charged for actual parking usage after 7:00 PM.',
          ),
          _FaqTile(
            question: 'How does ANPR verify my vehicle?',
            answer:
                'The system checks your plate number against the university vehicle record.',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // INPUT WIDGETS
  // =====================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isSubmitting,
      maxLines: maxLines,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: AppTheme.primaryBlue,
      decoration: _inputDecoration(
        label: label,
        hintText: hintText,
        icon: icon,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<_IssueOption> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
        decoration: _inputDecoration(
        label: label,
        hintText: label,
        icon: icon,
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: _isSubmitting ? null : onChanged,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: AppTheme.primaryBlue,
        size: 21,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
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
        onPressed: _isSubmitting ? null : _submitIssue,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.3,
                ),
              )
            : const Icon(Icons.report_problem_rounded),
        label: Text(_isSubmitting ? 'Submitting...' : 'Submit Issue'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.68),
          foregroundColor: Colors.white,
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

  // =====================================================
  // SUBMIT ISSUE
  // =====================================================

  Future<void> _submitIssue() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (title.length < 5) {
      _showMessage(
        'Please enter an issue title with at least 5 characters.',
        isError: true,
      );
      return;
    }

    if (description.length < 10) {
      _showMessage(
        'Please describe the issue with at least 10 characters.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final SupportIssueResult result =
          await _supportIssueService.createCurrentUserSupportIssue(
        title: title,
        issueType: _selectedIssueType,
        priority: _selectedPriority,
        description: description,
        relatedPlate: _emptyToNull(_plateController.text),
        relatedBay: _emptyToNull(_bayController.text),
        relatedBookingReference: _emptyToNull(
          _bookingReferenceController.text,
        ),
      );

      if (!mounted) return;

      _clearForm();

      await _showSuccessDialog(result);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to submit issue: $error',
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

  String? _emptyToNull(String value) {
    final String cleanValue = value.trim();

    if (cleanValue.isEmpty) return null;

    return cleanValue;
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _plateController.clear();
    _bayController.clear();
    _bookingReferenceController.clear();

    setState(() {
      _selectedIssueType = 'general';
      _selectedPriority = 'medium';
    });
  }

  Future<void> _showSuccessDialog(SupportIssueResult result) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Issue Submitted',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Your support issue has been sent to the parking administrator.\n\n'
            'Reference: ${result.issueReference}\n'
            'Status: ${_formatLabel(result.status)}\n'
            'Priority: ${_formatLabel(result.priority)}',
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
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
      ),
    );
  }

  String _formatLabel(String value) {
    return value
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;

          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}

// =====================================================
// ISSUE OPTION
// =====================================================

class _IssueOption {
  final String value;
  final String label;

  const _IssueOption({
    required this.value,
    required this.label,
  });
}

// =====================================================
// WIDGETS
// =====================================================

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8EEF7),
          ),
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
    );
  }
}

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
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
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
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool showDivider;

  const _FaqTile({
    required this.question,
    required this.answer,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          answer,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.2,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFE8EEF7),
          ),
          const SizedBox(height: 13),
        ],
      ],
    );
  }
}