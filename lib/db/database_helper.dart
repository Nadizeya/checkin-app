import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class SessionRecord {
  final String id;
  final String studentId;
  final String studentName;
  final double checkinLat;
  final double checkinLng;
  final String checkinTime;
  final String qrCodeData;
  final String previousTopic;
  final String expectedTopic;
  final int moodScore;
  final double? checkoutLat;
  final double? checkoutLng;
  final String? checkoutTime;
  final String? learnedToday;
  final String? feedback;
  final bool isComplete;

  SessionRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.checkinLat,
    required this.checkinLng,
    required this.checkinTime,
    required this.qrCodeData,
    required this.previousTopic,
    required this.expectedTopic,
    required this.moodScore,
    this.checkoutLat,
    this.checkoutLng,
    this.checkoutTime,
    this.learnedToday,
    this.feedback,
    this.isComplete = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'checkinLat': checkinLat,
        'checkinLng': checkinLng,
        'checkinTime': checkinTime,
        'qrCodeData': qrCodeData,
        'previousTopic': previousTopic,
        'expectedTopic': expectedTopic,
        'moodScore': moodScore,
        'checkoutLat': checkoutLat,
        'checkoutLng': checkoutLng,
        'checkoutTime': checkoutTime,
        'learnedToday': learnedToday,
        'feedback': feedback,
        'isComplete': isComplete,
      };

  factory SessionRecord.fromMap(Map<String, dynamic> m) => SessionRecord(
        id: m['id'],
        studentId: m['studentId'],
        studentName: m['studentName'],
        checkinLat: (m['checkinLat'] as num).toDouble(),
        checkinLng: (m['checkinLng'] as num).toDouble(),
        checkinTime: m['checkinTime'],
        qrCodeData: m['qrCodeData'],
        previousTopic: m['previousTopic'],
        expectedTopic: m['expectedTopic'],
        moodScore: m['moodScore'],
        checkoutLat: m['checkoutLat'] != null
            ? (m['checkoutLat'] as num).toDouble()
            : null,
        checkoutLng: m['checkoutLng'] != null
            ? (m['checkoutLng'] as num).toDouble()
            : null,
        checkoutTime: m['checkoutTime'],
        learnedToday: m['learnedToday'],
        feedback: m['feedback'],
        isComplete: m['isComplete'] ?? false,
      );
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const _key = 'smartcheckin_sessions';

  List<SessionRecord> _readAll() {
    final raw = html.window.localStorage[_key];
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => SessionRecord.fromMap(e)).toList();
  }

  void _writeAll(List<SessionRecord> sessions) {
    html.window.localStorage[_key] =
        jsonEncode(sessions.map((s) => s.toMap()).toList());
  }

  Future<void> insertSession(SessionRecord s) async {
    final all = _readAll();
    all.removeWhere((e) => e.id == s.id);
    all.add(s);
    _writeAll(all);
  }

  Future<void> updateSession(SessionRecord s) async {
    final all = _readAll();
    final idx = all.indexWhere((e) => e.id == s.id);
    if (idx != -1) all[idx] = s;
    _writeAll(all);
  }

  Future<List<SessionRecord>> getAllSessions() async {
    final all = _readAll();
    all.sort((a, b) => b.checkinTime.compareTo(a.checkinTime));
    return all;
  }

  Future<SessionRecord?> getActiveSession() async {
    final all = _readAll();
    try {
      return all.firstWhere((s) => !s.isComplete);
    } catch (_) {
      return null;
    }
  }

  Future<int> countSessions() async {
    return _readAll().where((s) => s.isComplete).length;
  }

  Future<double> avgMood() async {
    final done = _readAll().where((s) => s.isComplete).toList();
    if (done.isEmpty) return 0.0;
    return done.fold(0, (s, r) => s + r.moodScore) / done.length;
  }
}
