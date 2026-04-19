import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';

class ActiveScreen extends StatelessWidget {
  const ActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _FilterChip(label: 'All', active: provider.statusFilter == null,
                  onTap: () => provider.setFilter(null)),
              ...AppStatus.values.map((s) => _FilterChip(
                    label: s.label, active: provider.statusFilter == s,
                    color: s.color, onTap: () => provider.setFilter(s),
                  )),
            ],
          ),
        ),
        // Stats mini-row
        _StatsRow(provider: provider),
        // List
        Expanded(
          child: provider.active.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('📋', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 10),
                  Text(provider.searchQuery.isNotEmpty
                      ? 'No results for "${provider.searchQuery}"'
                      : 'No applications yet',
                      style: const TextStyle(color: Color(0xFF7A84A8), fontSize: 14)),
                ]))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: provider.active.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final list = List<JobApplication>.from(provider.active);
                    provider.reorder(list[oldIndex].id, list[newIndex].id);
                  },
                  itemBuilder: (ctx, i) {
                    final job = provider.active[i];
                    return JobCard(key: ValueKey(job.id), job: job, index: i);
                  },
                ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final JobProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        _StatPill('${provider.totalActive}', 'total', Colors.white70),
        const SizedBox(width: 8),
        _StatPill('${provider.count(AppStatus.interviewing)}', 'interviews', const Color(0xFFF5A623)),
        const SizedBox(width: 8),
        _StatPill('${provider.count(AppStatus.offered)}', 'offers', const Color(0xFF34D399)),
        const SizedBox(width: 8),
        _StatPill('${provider.responseRate}%', 'response', const Color(0xFF7C6AF7)),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String num, label;
  final Color color;
  const _StatPill(this.num, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(text: TextSpan(children: [
        TextSpan(text: num, style: TextStyle(color: color, fontSize: 13,
            fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
        TextSpan(text: ' $label', style: const TextStyle(color: Color(0xFF9AA3BF), fontSize: 11)),
      ])),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.active,
      required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7C6AF7);
    final c = color ?? accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        decoration: BoxDecoration(
          color: active ? c.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? c : const Color(0xFF2A2E3F)),
        ),
        child: Text(label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: active ? c : const Color(0xFF9AA3BF))),
      ),
    );
  }
}