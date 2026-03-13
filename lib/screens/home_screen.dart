import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../db/database_helper.dart';
import 'checkin_screen.dart';
import 'history_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  const HomeScreen(
      {super.key, required this.studentId, required this.studentName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _sessionCount = 0;
  double _avgMood = 0;
  SessionRecord? _lastSession;
  SessionRecord? _activeSession;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final count = await DatabaseHelper.instance.countSessions();
    final avg = await DatabaseHelper.instance.avgMood();
    final all = await DatabaseHelper.instance.getAllSessions();
    final active = await DatabaseHelper.instance.getActiveSession();
    setState(() {
      _sessionCount = count;
      _avgMood = avg;
      _lastSession = all.where((s) => s.isComplete).isNotEmpty
          ? all.firstWhere((s) => s.isComplete)
          : null;
      _activeSession = active;
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _initials {
    final parts = widget.studentName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      HistoryScreen(studentId: widget.studentId),
      ProgressScreen(studentId: widget.studentId),
    ];

    return Scaffold(
      body: pages[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) {
          setState(() => _navIndex = i);
          if (i == 0) _loadData();
        },
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.blueLight,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.blue),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon:
                  Icon(Icons.history_rounded, color: AppColors.blue),
              label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon:
                  Icon(Icons.bar_chart_rounded, color: AppColors.blue),
              label: 'Progress'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.blueLight,
                  child: Text(_initials,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blue)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_greeting, ${widget.studentName.split(' ').first}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                      Text(
                          DateFormat('EEEE · d MMM yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              const Divider(color: AppColors.border, thickness: 0.5),
              const SizedBox(height: 16),

              // Active session warning
              if (_activeSession != null) ...[
                _activeSessionBanner(),
                const SizedBox(height: 16),
              ],

              // Stats
              Row(children: [
                Expanded(child: _statCard('$_sessionCount', 'Sessions done')),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard(
                        _avgMood > 0 ? _avgMood.toStringAsFixed(1) : '—',
                        'Avg mood')),
              ]),
              const SizedBox(height: 16),

              // Attendance progress
              _sectionLabel('ATTENDANCE THIS MONTH'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(_sessionCount * 8).clamp(0, 100)}%',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.blue,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_sessionCount / 12).clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: AppColors.surface,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.blue),
                ),
              ),
              const SizedBox(height: 20),

              // Last session
              _sectionLabel('LAST SESSION'),
              const SizedBox(height: 8),
              _lastSessionCard(),
              const SizedBox(height: 24),
              const Divider(color: AppColors.border, thickness: 0.5),
              const SizedBox(height: 20),

              // Check-in button
              ElevatedButton.icon(
                onPressed: _activeSession != null
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckinScreen(
                              studentId: widget.studentId,
                              studentName: widget.studentName,
                            ),
                          ),
                        );
                        _loadData();
                      },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: Text(_activeSession != null
                    ? 'Session already active'
                    : 'Check-in to class'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeSessionBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C080), width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.access_time_rounded,
            color: AppColors.amber, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Active session',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.amber)),
              Text(
                  'Checked in at ${_activeSession!.checkinTime.substring(11, 16)}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.amber)),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            await Navigator.pushNamed(context, '/finish');
            _loadData();
          },
          child: const Text('Finish',
              style: TextStyle(color: AppColors.amber, fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textTertiary)),
      ]),
    );
  }

  Widget _lastSessionCard() {
    if (_lastSession == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: const Text('No sessions yet',
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
      );
    }
    final dt = DateTime.parse(_lastSession!.checkinTime);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('EEE d MMM · HH:mm').format(dt),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            _badge('Complete', AppColors.greenLight, AppColors.green),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(_lastSession!.expectedTopic,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary)),
        ),
      ]),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            letterSpacing: 0.5));
  }
}
