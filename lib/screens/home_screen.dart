import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import 'active_screen.dart';
import 'archive_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _navItems = [
    (icon: Icons.grid_view_rounded,    label: 'Active'),
    (icon: Icons.inventory_2_outlined, label: 'Archive'),
    (icon: Icons.history_rounded,      label: 'History'),
    (icon: Icons.bar_chart_rounded,    label: 'Stats'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──
          NavigationRail(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            backgroundColor: const Color(0xFF12151E),
            indicatorColor: const Color(0xFF7C6AF7).withValues(alpha: 0.15),
            selectedIconTheme: const IconThemeData(color: Color(0xFF7C6AF7)),
            selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF7C6AF7), fontSize: 11, fontWeight: FontWeight.w600),
            unselectedIconTheme: const IconThemeData(color: Color(0xFF5A6080)),
            unselectedLabelTextStyle: const TextStyle(color: Color(0xFF5A6080), fontSize: 11),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 20),
              child: Column(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C6AF7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text('JT', style: TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            destinations: _navItems.map((item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            )).toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E2336)),
          // ── Content ──
          Expanded(
            child: Column(
              children: [
                _TopBar(tab: _tab),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: const [
                      ActiveScreen(),
                      ArchiveScreen(),
                      HistoryScreen(),
                      StatsScreen(),
                    ],
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

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int tab;
  const _TopBar({required this.tab});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<JobProvider>();
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF12151E),
        border: Border(bottom: BorderSide(color: Color(0xFF1E2336))),
      ),
      child: Row(
        children: [
          if (tab == 0) ...[
            Expanded(
              child: TextField(
                style: const TextStyle(fontSize: 13, color: Color(0xFFE2E6F0)),
                decoration: InputDecoration(
                  hintText: 'Search company or role…',
                  hintStyle: const TextStyle(color: Color(0xFF5A6080), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF5A6080)),
                  filled: true,
                  fillColor: const Color(0xFF181C28),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: Color(0xFF1E2336)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: Color(0xFF1E2336)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: Color(0xFF7C6AF7)),
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: provider.setSearch,
              ),
            ),
            const SizedBox(width: 8),
            const _SortButton(),
            const SizedBox(width: 8),
          ] else
            const Spacer(),
          const _AddButton(),
        ],
      ),
    );
  }
}

// ── Sort button ───────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  const _SortButton();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobProvider>();
    final labels = {
      SortBy.date:     'Date',
      SortBy.company:  'Name',
      SortBy.status:   'Status',
      SortBy.priority: 'Pin',
      SortBy.manual:   'Manual',
    };
    return PopupMenuButton<String>(
      color: const Color(0xFF181C28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF181C28),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E2336)),
        ),
        child: Row(children: [
          const Icon(Icons.sort_rounded, size: 15, color: Color(0xFF9AA3BF)),
          const SizedBox(width: 5),
          Text(labels[provider.sortBy]!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA3BF))),
        ]),
      ),
      itemBuilder: (_) => [
        // Only show non-manual sort options — manual is set automatically on drag
        ...SortBy.values
            .where((s) => s != SortBy.manual)
            .map((s) => PopupMenuItem(
                  value: 'sort_${s.name}',
                  child: Row(children: [
                    Text(labels[s]!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFE2E6F0))),
                    if (provider.sortBy == s)
                      const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 14, color: Color(0xFF7C6AF7))),
                  ]),
                )),
        const PopupMenuDivider(),
        PopupMenuItem(
            value: 'asc',
            child: Row(children: [
              const Text('Ascending',
                  style: TextStyle(fontSize: 13, color: Color(0xFFE2E6F0))),
              if (provider.sortAsc)
                const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 14, color: Color(0xFF7C6AF7))),
            ])),
        PopupMenuItem(
            value: 'desc',
            child: Row(children: [
              const Text('Descending',
                  style: TextStyle(fontSize: 13, color: Color(0xFFE2E6F0))),
              if (!provider.sortAsc)
                const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 14, color: Color(0xFF7C6AF7))),
            ])),
      ],
      onSelected: (v) {
        if (v.startsWith('sort_')) {
          provider.setSort(SortBy.values.firstWhere((s) => s.name == v.substring(5)));
        } else {
          provider.setSortOrder(v == 'asc');
        }
      },
    );
  }
}

// ── Add button + sheet ────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF7C6AF7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      onPressed: () => _showAddSheet(context),
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  void _showAddSheet(BuildContext context) {
    final companyCtrl = TextEditingController();
    final roleCtrl    = TextEditingController();
    final notesCtrl   = TextEditingController();
    var status = AppStatus.applied;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181C28),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              const Text('New application',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE2E6F0))),
              const SizedBox(height: 18),
              _field('Company', companyCtrl, 'e.g. Stripe'),
              const SizedBox(height: 12),
              _field('Role', roleCtrl, 'e.g. Flutter Developer'),
              const SizedBox(height: 14),
              const Text('STATUS',
                  style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF5A6080),
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                children: AppStatus.values.map((s) => GestureDetector(
                  onTap: () => ss(() => status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == s ? s.bgColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: status == s ? s.color : const Color(0xFF2A2E3F)),
                    ),
                    child: Text(s.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status == s ? s.color : const Color(0xFF7A84A8))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 14),
              _field('Notes', notesCtrl, 'Optional details…', maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C6AF7),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (companyCtrl.text.isNotEmpty && roleCtrl.text.isNotEmpty) {
                      context.read<JobProvider>().addJob(
                          companyCtrl.text.trim(),
                          roleCtrl.text.trim(),
                          status,
                          notesCtrl.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add application',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF5A6080),
                letterSpacing: 0.7,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Color(0xFFE2E6F0)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3A3E50), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0C0E14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A2E3F))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2A2E3F))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF7C6AF7))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}