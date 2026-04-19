import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';

enum _HistoryView { feed, byJob }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryView _view = _HistoryView.feed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HistoryToolbar(
          view: _view,
          onViewChanged: (v) => setState(() => _view = v),
        ),
        Expanded(
          child: _view == _HistoryView.feed
              ? const _GlobalFeed()
              : const _ByJobList(),
        ),
      ],
    );
  }
}

// ── Toolbar ──────────────────────────────────────────────────────────────────

class _HistoryToolbar extends StatelessWidget {
  final _HistoryView view;
  final ValueChanged<_HistoryView> onViewChanged;

  const _HistoryToolbar({required this.view, required this.onViewChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E2336))),
      ),
      child: Row(
        children: [
          _ViewToggle(selected: view, onChanged: onViewChanged),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final _HistoryView selected;
  final ValueChanged<_HistoryView> onChanged;

  const _ViewToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF1E2336)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'Activity feed',
            icon: Icons.dynamic_feed_rounded,
            active: selected == _HistoryView.feed,
            onTap: () => onChanged(_HistoryView.feed),
          ),
          const SizedBox(width: 3),
          _ToggleChip(
            label: 'By job',
            icon: Icons.work_outline_rounded,
            active: selected == _HistoryView.byJob,
            onTap: () => onChanged(_HistoryView.byJob),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF7C6AF7).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active
                ? const Color(0xFF7C6AF7).withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 13,
                color: active ? const Color(0xFF7C6AF7) : const Color(0xFF5A6080)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? const Color(0xFF7C6AF7) : const Color(0xFF5A6080),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Global feed ───────────────────────────────────────────────────────────────

class _GlobalFeed extends StatelessWidget {
  const _GlobalFeed();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();

    final entries = <({JobApplication job, HistoryEntry entry})>[];
    for (final job in provider.allJobs) {
      for (final entry in job.history) {
        entries.add((job: job, entry: entry));
      }
    }
    entries.sort((a, b) => b.entry.at.compareTo(a.entry.at));

    if (entries.isEmpty) {
      return const _EmptyState(
        message: 'No activity yet — add your first application to get started.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: entries.length,
      itemBuilder: (ctx, i) {
        final item = entries[i];
        final showDateHeader =
            i == 0 || !_sameDay(entries[i - 1].entry.at, item.entry.at);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) _DateHeader(date: item.entry.at),
            _FeedEntry(job: item.job, entry: item.entry),
          ],
        );
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        _formatDate(date),
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF6B7494),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _FeedEntry extends StatelessWidget {
  final JobApplication job;
  final HistoryEntry entry;

  const _FeedEntry({required this.job, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 5),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: entry.status?.color ?? const Color(0xFF5A6080),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF12151E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E2336)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFCDD2E0),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${job.company} · ${job.role}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7494),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(entry.at),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF5A6080),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── By-job list ───────────────────────────────────────────────────────────────

class _ByJobList extends StatelessWidget {
  const _ByJobList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();
    final jobs = provider.allJobs
        .where((j) => j.history.isNotEmpty)
        .toList()
      ..sort((a, b) => b.history.last.at.compareTo(a.history.last.at));

    if (jobs.isEmpty) {
      return const _EmptyState(
        message: 'No activity yet — add your first application to get started.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => _JobHistoryCard(job: jobs[i]),
    );
  }
}

class _JobHistoryCard extends StatefulWidget {
  final JobApplication job;
  const _JobHistoryCard({required this.job});

  @override
  State<_JobHistoryCard> createState() => _JobHistoryCardState();
}

class _JobHistoryCardState extends State<_JobHistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entries = widget.job.history.reversed.toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF12151E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E2336)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.company,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE2E6F0),
                          ),
                        ),
                        Text(
                          widget.job.role,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9AA3BF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.job.status.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.job.status.label,
                      style: TextStyle(
                        color: widget.job.status.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2336),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${entries.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA3BF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: Color(0xFF5A6080),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1, color: Color(0xFF1E2336)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    children: entries.map((e) => _InlineEntry(entry: e)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineEntry extends StatelessWidget {
  final HistoryEntry entry;
  const _InlineEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: entry.status?.color ?? const Color(0xFF5A6080),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFCDD2E0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(entry.at),
            style: const TextStyle(fontSize: 10, color: Color(0xFF5A6080)),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('◷', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF6B7494), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  if (_sameDay(dt, now)) return 'TODAY';
  if (_sameDay(dt, now.subtract(const Duration(days: 1)))) return 'YESTERDAY';
  final months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}