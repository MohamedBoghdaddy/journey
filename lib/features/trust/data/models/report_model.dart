import '../../domain/entities/report.dart';

class ReportModel {
  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.details,
    this.createdAt,
  });

  final String id;
  final String reporterId;
  final String targetType;
  final String targetId;
  final String reason;
  final String? details;
  final DateTime? createdAt;

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: (map['id'] ?? '').toString(),
      reporterId: (map['reporter_id'] ?? '').toString(),
      targetType: (map['target_type'] ?? '').toString(),
      targetId: (map['target_id'] ?? '').toString(),
      reason: (map['reason'] ?? '').toString(),
      details: map['details']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'reporter_id': reporterId,
    'target_type': targetType,
    'target_id': targetId,
    'reason': reason,
    'details': details,
  };

  Report toEntity() => Report(
    id: id,
    reporterId: reporterId,
    targetType: targetType,
    targetId: targetId,
    reason: reason,
    details: details,
    createdAt: createdAt,
  );
}
