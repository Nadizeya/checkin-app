import 'package:flutter/material.dart';
import '../theme.dart';
import '../db/database_helper.dart';

class ProgressScreen extends StatefulWidget {
  final String studentId;
  const ProgressScreen({super.key, required this.studentId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<SessionRecord> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await DatabaseHelper.instance.getAllSessions();
    setState(() {
      _sessions = all.where((s) => s.isComplete).toList();
      _loading = false;
    });
  }

  List<double> _weeklyMood() {
    final now = DateTime.now();
    final result = List<double>.filled(7, 0);
    final counts = List<int>.filled(7, 0);
    for (final s in _sessions) {
      final dt = DateTime.parse(s.checkinTime);
      final diff = now.weekday - dt.weekday;
      final idx = 6 - diff.abs();
      if (idx >= 0 && idx < 7) {
        result[idx] += s.moodScore;
        counts[idx]++;
      }
    }
    for (int i = 0; i < 7; i++) {
      result[i] = counts[i] > 0 ? result[i] / counts[i] : 0;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final totalSessions = _sessions.length;
    final avgMood = totalSessions > 0
        ? (_sessions.fold(0, (s, r) => s + r.moodScore) / totalSessions)
        : 0.0;
    final weekMoods = _weeklyMood();
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Scaffold(
      appBar: AppBar(title: const Text('My progress')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              Row(children: [
                Expanded(child: _statCard('$totalSessions', 'Total sessions')),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard(
                        avgMood > 0
                            ? avgMood.toStringAsFixed(1)
                            : '—',
                        'Avg mood')),
              ]),
              const SizedBox(height: 20),

              // Mood bar chart
              _sectionLabel('MOOD THIS WEEK'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (i) {
                    final val = weekMoods[i];
                    final maxH = 80.0;
                    final barH = val > 0 ? (val / 5) * maxH : 8.0;
                    final isToday = i == DateTime.now().weekday - 1;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 24,
                          height: barH,
                          decoration: BoxDecoration(
                            color: val > 0
                                ? (isToday
                                    ? AppColors.blue
                                    : AppColors.blueMid.withOpacity(0.6))
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(days[i],
                            style: TextStyle(
                                fontSize: 11,
                                color: isToday
                                    ? AppColors.blue
                                    : AppColors.textTertiary,
                                fontWeight: isToday
                                    ? FontWeight.w500
                                    : FontWeight.w400)),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Streak
              _sectionLabel('ATTENDANCE STREAK'),
              const SizedBox(height: 10),
              _buildStreak(),
              const SizedBox(height: 20),

              // Tip card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFB5D4F4), width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.blue, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Attendance tip',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blue)),
                          const SizedBox(height: 4),
                          Text(
                            totalSessions >= 10
                                ? 'Great work! You\'re maintaining excellent attendance.'
                                : 'Keep checking in regularly to build a strong attendance record!',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF0C447C)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreak() {
    final now = DateTime.now();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(14, (i) {
        final day = now.subtract(Duration(days: 13 - i));
        final attended = _sessions.any((s) {
          final dt = DateTime.parse(s.checkinTime);
          return dt.year == day.year &&
              dt.month == day.month &&
              dt.day == day.day;
        });
        final isFuture = day.isAfter(now);
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isFuture
                ? AppColors.surface
                : attended
                    ? AppColors.blue
                    : AppColors.redLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: isFuture ? AppColors.border : Colors.transparent,
                width: 0.5),
          ),
          child: Center(
            child: isFuture
                ? null
                : Icon(
                    attended ? Icons.check_rounded : Icons.close_rounded,
                    size: 14,
                    color: attended ? Colors.white : AppColors.red,
                  ),
          ),
        );
      }),
    );
  }

  Widget _statCard(String value, String label) => Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
          letterSpacing: 0.5));
}
