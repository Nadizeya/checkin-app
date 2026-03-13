import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../db/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  final String studentId;
  const HistoryScreen({super.key, required this.studentId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      _sessions = all;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session history')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(
                  child: Text('No sessions yet',
                      style: TextStyle(color: AppColors.textTertiary)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _sessionTile(_sessions[i]),
                  ),
                ),
    );
  }

  Widget _sessionTile(SessionRecord s) {
    final dt = DateTime.parse(s.checkinTime);
    final moodEmoji = ['😡', '🙁', '😐', '🙂', '😄'][s.moodScore - 1];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(DateFormat('EEE d MMM yyyy · HH:mm').format(dt),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
          _badge(
            s.isComplete ? 'Complete' : 'Incomplete',
            s.isComplete ? AppColors.greenLight : AppColors.redLight,
            s.isComplete ? AppColors.green : AppColors.red,
          ),
        ]),
        const SizedBox(height: 6),
        Text('Topic: ${s.expectedTopic}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Row(children: [
          Text('Mood: $moodEmoji',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Icon(Icons.location_on_rounded,
              size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 2),
          Text(
              '${s.checkinLat.toStringAsFixed(3)}, '
              '${s.checkinLng.toStringAsFixed(3)}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
        ]),
        if (s.isComplete && s.learnedToday != null) ...[
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, thickness: 0.5),
          const SizedBox(height: 6),
          Text('Learned: ${s.learnedToday}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ]),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
      );
}
