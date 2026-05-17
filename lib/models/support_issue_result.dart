// =====================================================
// SUPPORT ISSUE RESULT MODEL
// =====================================================

class SupportIssueResult {
  final String issueId;
  final String issueReference;
  final String status;
  final String priority;
  final DateTime? createdAt;

  const SupportIssueResult({
    required this.issueId,
    required this.issueReference,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON
  // =====================================================

  factory SupportIssueResult.fromJson(Map<String, dynamic> json) {
    return SupportIssueResult(
      issueId: json['issue_id']?.toString() ?? '',
      issueReference: json['issue_reference']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'medium',
      createdAt: _toDateTime(json['created_at']),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString())?.toLocal();
  }
}