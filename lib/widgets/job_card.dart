import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';

class JobCard extends StatefulWidget {
  final JobApplication job;
  final int index;
  const JobCard({super.key, required this.job, required this.index});
  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _notesOpen = false;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = widget.job.notes;
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  Color _avatarBg(String c) {
    const bgs = [Color(0xFF1E3A5F),Color(0xFF3B2A1A),Color(0xFF1A3B2A),
                 Color(0xFF2A1A3B),Color(0xFF3B1A1A),Color(0xFF1C2A3B)];
    return bgs[c.codeUnitAt(0) % bgs.length];
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final provider = context.read<JobProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF12151E),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: job.pinned ? const Color(0xFF7C6AF7).withValues(alpha: 0.35) : const Color(0xFF1E2336),
        ),
      ),
      child: Column(
        children: [
          // Pin indicator
          if (job.pinned)
            Container(height: 2, decoration: BoxDecoration(
                color: const Color(0xFF7C6AF7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)))),
          // Card row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Drag handle — index must match position in ReorderableListView
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.drag_indicator_rounded,
                        size: 16, color: Color(0xFF5A6080)),
                  ),
                ),
                // Avatar
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _avatarBg(job.company),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    job.company.length >= 2 ? job.company.substring(0, 2).toUpperCase() : job.company,
                    style: TextStyle(color: job.status.color, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 11),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.company,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE2E6F0)),
                          overflow: TextOverflow.ellipsis),
                      Text(job.role,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9AA3BF)),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Date
                Text(
                  '${job.addedAt.day} ${const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][job.addedAt.month - 1]}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7494),
                      fontFeatures: [FontFeature.tabularFigures()]),
                ),
                const SizedBox(width: 8),
                // Status badge
                GestureDetector(
                  onTap: () => _showStatusSheet(context, provider),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: job.status.bgColor, borderRadius: BorderRadius.circular(16)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 5, height: 5,
                          decoration: BoxDecoration(color: job.status.color, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(job.status.label, style: TextStyle(
                          color: job.status.color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 6),
                // Actions
                IconButton(
                  padding: const EdgeInsets.all(4), constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => provider.togglePin(job.id),
                  icon: Icon(job.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: 15, color: job.pinned ? const Color(0xFFA78BFA) : const Color(0xFF5A6080)),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4), constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _notesOpen = !_notesOpen),
                  icon: Icon(Icons.notes_rounded, size: 15,
                      color: _notesOpen ? const Color(0xFF7C6AF7) : const Color(0xFF5A6080)),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4), constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => provider.archiveJob(job.id),
                  icon: const Icon(Icons.inventory_2_outlined, size: 15, color: Color(0xFF5A6080)),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4), constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmDelete(context, provider),
                  icon: const Icon(Icons.close_rounded, size: 15, color: Color(0xFF5A6080)),
                ),
              ],
            ),
          ),
          // Notes
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _notesOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 14, 12),
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 3, minLines: 2,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFCDD2E0)),
                      decoration: InputDecoration(
                        hintText: 'Notes about this application…',
                        hintStyle: const TextStyle(color: Color(0xFF5A6080), fontSize: 12),
                        filled: true, fillColor: const Color(0xFF0C0E14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2A2E3F))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2A2E3F))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF7C6AF7))),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      onChanged: (v) => provider.updateNotes(job.id, v),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showStatusSheet(BuildContext context, JobProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181C28),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          ...AppStatus.values.map((s) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(width: 8, height: 8,
                    decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                title: Text(s.label, style: TextStyle(color: s.color, fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: widget.job.status == s
                    ? Icon(Icons.check_rounded, color: s.color, size: 16) : null,
                onTap: () { provider.updateStatus(widget.job.id, s); Navigator.pop(ctx); },
              )),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, JobProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181C28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete application?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFE2E6F0))),
        content: Text('${widget.job.company} — ${widget.job.role} will be permanently removed.',
            style: const TextStyle(color: Color(0xFF9AA3BF), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF9AA3BF)))),
          TextButton(
            onPressed: () { provider.deleteJob(widget.job.id); Navigator.pop(ctx); },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}