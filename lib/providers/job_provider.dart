import 'package:flutter/material.dart';
import '../models/job.dart';

enum SortBy { date, company, status, priority, manual }

class JobProvider extends ChangeNotifier {
  final List<JobApplication> _jobs = [
    JobApplication(id: 1, company: 'Stripe', role: 'Flutter Developer',
        status: AppStatus.interviewing, pinned: true,
        notes: 'Had a great first call. Follow up Monday.',
        addedAt: DateTime(2026, 4, 18)),
    JobApplication(id: 2, company: 'Linear', role: 'Mobile Engineer',
        addedAt: DateTime(2026, 4, 15)),
    JobApplication(id: 3, company: 'Vercel', role: 'Software Engineer',
        status: AppStatus.offered, notes: 'Salary: 120k. Deadline Apr 25.',
        addedAt: DateTime(2026, 4, 10)),
    JobApplication(id: 4, company: 'Notion', role: 'iOS Developer',
        status: AppStatus.rejected, addedAt: DateTime(2026, 4, 5)),
    JobApplication(id: 5, company: 'Figma', role: 'Flutter Engineer',
        addedAt: DateTime(2026, 4, 19)),
  ];

  final List<JobApplication> _archived = [];
  final List<HistoryEntry> globalHistory = [];

  SortBy sortBy = SortBy.date;
  bool sortAsc = false;
  AppStatus? statusFilter;
  String searchQuery = '';

  int _nextId = 6;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<JobApplication> get active {
    var list = _jobs.where((j) => !j.archived).toList();
    if (statusFilter != null) list = list.where((j) => j.status == statusFilter).toList();
    if (searchQuery.isNotEmpty) {
      list = list.where((j) =>
          j.company.toLowerCase().contains(searchQuery) ||
          j.role.toLowerCase().contains(searchQuery)).toList();
    }
    // Manual mode: respect _jobs insertion order, just keep pinned on top
    if (sortBy == SortBy.manual) {
      list.sort((a, b) => b.pinned ? 1 : (a.pinned ? -1 : 0));
      return list;
    }
    _sortList(list);
    // Pinned always on top unless sorting by priority
    if (sortBy != SortBy.priority) {
      list.sort((a, b) => b.pinned ? 1 : (a.pinned ? -1 : 0));
    }
    return list;
  }

  List<JobApplication> get all => List.unmodifiable(_jobs);
  List<JobApplication> get pinned => active.where((j) => j.pinned).toList();
  List<JobApplication> get unpinned => active.where((j) => !j.pinned).toList();
  List<JobApplication> get archived => List.unmodifiable(_archived);
  List<JobApplication> get allJobs => [..._jobs, ..._archived];

  int count(AppStatus s) => _jobs.where((j) => j.status == s).length;
  int get totalActive => _jobs.length;
  int get totalArchived => _archived.length;

  int get responseRate {
    if (_jobs.isEmpty) return 0;
    final responded = _jobs.where(
        (j) => j.status == AppStatus.interviewing || j.status == AppStatus.offered).length;
    return (responded / _jobs.length * 100).round();
  }

  int get offerRate {
    final total = _jobs.length + _archived.length;
    if (total == 0) return 0;
    final offers = (_jobs + _archived).where((j) => j.status == AppStatus.offered).length;
    return (offers / total * 100).round();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  void addJob(String company, String role, AppStatus status, String notes) {
    final job = JobApplication(
        id: _nextId++, company: company, role: role, status: status, notes: notes);
    _jobs.insert(0, job);
    _log('Added $company — $role');
    notifyListeners();
  }

  void updateStatus(int id, AppStatus status) {
    final j = _find(id);
    if (j == null) return;
    final old = j.status;
    j.status = status;
    j.history.add(HistoryEntry(
        description: '${old.label} → ${status.label}', status: status));
    _log('${j.company} moved to ${status.label}');
    notifyListeners();
  }

  void togglePin(int id) {
    final j = _find(id);
    if (j == null) return;
    j.pinned = !j.pinned;
    _log('${j.company} ${j.pinned ? 'pinned' : 'unpinned'}');
    notifyListeners();
  }

  void updateNotes(int id, String notes) {
    final j = _find(id);
    if (j == null) return;
    j.notes = notes;
    notifyListeners();
  }

  void archiveJob(int id) {
    final idx = _jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return;
    final j = _jobs.removeAt(idx);
    j.archived = true;
    _archived.insert(0, j);
    _log('Archived ${j.company}');
    notifyListeners();
  }

  void unarchiveJob(int id) {
    final idx = _archived.indexWhere((j) => j.id == id);
    if (idx == -1) return;
    final j = _archived.removeAt(idx);
    j.archived = false;
    _jobs.insert(0, j);
    _log('Restored ${j.company} from archive');
    notifyListeners();
  }

  void deleteJob(int id) {
    final j = _find(id);
    if (j != null) _log('Deleted ${j.company}');
    _jobs.removeWhere((j) => j.id == id);
    notifyListeners();
  }

  void deleteArchived(int id) {
    _archived.removeWhere((j) => j.id == id);
    notifyListeners();
  }

  /// Drag reorder — moves item in _jobs and switches to manual sort
  void reorder(int fromId, int toId) {
    final si = _jobs.indexWhere((j) => j.id == fromId);
    final ti = _jobs.indexWhere((j) => j.id == toId);
    if (si == -1 || ti == -1) return;
    final moved = _jobs.removeAt(si);
    _jobs.insert(ti, moved);
    sortBy = SortBy.manual; // lock to manual after drag
    notifyListeners();
  }

  void setSort(SortBy s) { sortBy = s; notifyListeners(); }
  void setSortOrder(bool asc) { sortAsc = asc; notifyListeners(); }
  void setFilter(AppStatus? s) { statusFilter = s; notifyListeners(); }
  void setSearch(String q) { searchQuery = q.toLowerCase(); notifyListeners(); }

  // ── Helpers ───────────────────────────────────────────────────────────────

  JobApplication? _find(int id) {
    try { return _jobs.firstWhere((j) => j.id == id); } catch (_) { return null; }
  }

  void _log(String msg) {
    globalHistory.insert(0, HistoryEntry(description: msg));
    if (globalHistory.length > 100) globalHistory.removeLast();
  }

  void _sortList(List<JobApplication> list) {
    switch (sortBy) {
      case SortBy.date:
        list.sort((a, b) => sortAsc ? a.addedAt.compareTo(b.addedAt) : b.addedAt.compareTo(a.addedAt));
      case SortBy.company:
        list.sort((a, b) => sortAsc ? a.company.compareTo(b.company) : b.company.compareTo(a.company));
      case SortBy.status:
        final ord = {AppStatus.applied: 0, AppStatus.interviewing: 1, AppStatus.offered: 2, AppStatus.rejected: 3};
        list.sort((a, b) => sortAsc ? ord[a.status]!.compareTo(ord[b.status]!) : ord[b.status]!.compareTo(ord[a.status]!));
      case SortBy.priority:
        list.sort((a, b) => b.pinned ? 1 : -1);
      case SortBy.manual:
        break; // no-op, insertion order is preserved
    }
  }
}