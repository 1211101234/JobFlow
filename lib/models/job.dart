import 'package:flutter/material.dart';

enum AppStatus { applied, interviewing, offered, rejected }

extension AppStatusExt on AppStatus {
  String get label => switch (this) {
        AppStatus.applied      => 'Applied',
        AppStatus.interviewing => 'Interviewing',
        AppStatus.offered      => 'Offered',
        AppStatus.rejected     => 'Rejected',
      };

  Color get color => switch (this) {
        AppStatus.applied      => const Color(0xFF4A9EFF),
        AppStatus.interviewing => const Color(0xFFF5A623),
        AppStatus.offered      => const Color(0xFF34D399),
        AppStatus.rejected     => const Color(0xFFF87171),
      };

  Color get bgColor => color.withValues(alpha: 0.12);
}

class HistoryEntry {
  final String description; // plain text summary
  final AppStatus? status;  // for status-change entries
  final DateTime at;

  HistoryEntry({required this.description, this.status}) : at = DateTime.now();
}

class JobApplication {
  final int id;
  String company;
  String role;
  AppStatus status;
  bool pinned;
  bool archived;
  String notes;
  final DateTime addedAt;
  final List<HistoryEntry> history;

  JobApplication({
    required this.id,
    required this.company,
    required this.role,
    this.status = AppStatus.applied,
    this.pinned = false,
    this.notes = '',
    DateTime? addedAt,
  })  : archived = false,
        addedAt = addedAt ?? DateTime.now(),
        history = [
          HistoryEntry(description: 'Application created', status: status)
        ];
}