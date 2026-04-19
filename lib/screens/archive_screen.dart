import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();
    final list = provider.archived;

    if (list.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('⊙', style: TextStyle(fontSize: 28)),
      SizedBox(height: 10),
      Text('Archive is empty', style: TextStyle(color: Color(0xFF5A6080), fontSize: 14)),
    ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final j = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF12151E).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E2336)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(j.company, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(j.role, style: const TextStyle(fontSize: 11, color: Color(0xFF5A6080))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: j.status.bgColor, borderRadius: BorderRadius.circular(12)),
              child: Text(j.status.label, style: TextStyle(
                  color: j.status.color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.restore_rounded, size: 16),
              color: const Color(0xFF7C6AF7),
              onPressed: () => provider.unarchiveJob(j.id),
              tooltip: 'Restore',
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16),
              color: const Color(0xFF5A6080),
              onPressed: () => provider.deleteArchived(j.id),
              tooltip: 'Delete',
            ),
          ]),
        );
      },
    );
  }
}