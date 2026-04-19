import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<JobProvider>();
    final statuses = [
      (AppStatus.applied,      'Applied',      const Color(0xFF4A9EFF)),
      (AppStatus.interviewing, 'Interviewing', const Color(0xFFF5A623)),
      (AppStatus.offered,      'Offered',      const Color(0xFF34D399)),
      (AppStatus.rejected,     'Rejected',     const Color(0xFFF87171)),
    ];
    final total = p.totalActive + p.totalArchived;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary cards
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2, crossAxisSpacing: 8, mainAxisSpacing: 8,
          children: [
            _StatCard('${p.totalActive}', 'Active', Colors.white70),
            _StatCard('${p.responseRate}%', 'Response rate', const Color(0xFF7C6AF7)),
            _StatCard('${p.offerRate}%', 'Offer rate', const Color(0xFF34D399)),
            _StatCard('${p.totalArchived}', 'Archived', const Color(0xFF5A6080)),
          ],
        ),
        const SizedBox(height: 20),
        const Text('PIPELINE BREAKDOWN', style: TextStyle(fontSize: 10, color: Color(0xFF5A6080),
            letterSpacing: 0.8, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...statuses.map((s) {
          final count = p.count(s.$1);
          final pct = total > 0 ? count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(s.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: s.$3)),
                Text('$count · ${(pct * 100).round()}%',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF7A84A8),
                        fontFeatures: [FontFeature.tabularFigures()])),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: const Color(0xFF1E2336),
                  valueColor: AlwaysStoppedAnimation(s.$3),
                  minHeight: 4,
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String num, label;
  final Color color;
  const _StatCard(this.num, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12151E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E2336)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(num, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color,
            fontFeatures: const [FontFeature.tabularFigures()])),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF5A6080),
            fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      ]),
    );
  }
}