import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme.dart';
import '../db/database_helper.dart';
import 'home_screen.dart';

class FinishScreen extends StatefulWidget {
  final SessionRecord session;
  const FinishScreen({super.key, required this.session});

  @override
  State<FinishScreen> createState() => _FinishScreenState();
}

class _FinishScreenState extends State<FinishScreen> {
  Position? _position;
  String? _qrResult;
  bool _scannerOpen = false;
  bool _loading = false;

  final _learnedCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _position = pos);
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  String _duration() {
    final start = DateTime.parse(widget.session.checkinTime);
    final diff = DateTime.now().difference(start);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  Future<void> _finishClass() async {
    if (_position == null) {
      _snack('Waiting for GPS location...');
      return;
    }
    if (_qrResult == null) {
      _snack('Please scan the class QR code again');
      return;
    }
    if (_learnedCtrl.text.isEmpty) {
      _snack('Please fill in what you learned today');
      return;
    }

    setState(() => _loading = true);

    final updated = SessionRecord(
      id: widget.session.id,
      studentId: widget.session.studentId,
      studentName: widget.session.studentName,
      checkinLat: widget.session.checkinLat,
      checkinLng: widget.session.checkinLng,
      checkinTime: widget.session.checkinTime,
      qrCodeData: widget.session.qrCodeData,
      previousTopic: widget.session.previousTopic,
      expectedTopic: widget.session.expectedTopic,
      moodScore: widget.session.moodScore,
      checkoutLat: _position!.latitude,
      checkoutLng: _position!.longitude,
      checkoutTime: DateTime.now().toIso8601String(),
      learnedToday: _learnedCtrl.text.trim(),
      feedback: _feedbackCtrl.text.trim(),
      isComplete: true,
    );

    await DatabaseHelper.instance.updateSession(updated);
    setState(() => _loading = false);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: AppColors.greenMid, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Session complete!',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('You attended for ${_duration()}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(
                    studentId: widget.session.studentId,
                    studentName: widget.session.studentName,
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    if (_scannerOpen) return _buildScanner();

    final checkinTime = DateTime.parse(widget.session.checkinTime);

    return Scaffold(
      appBar: AppBar(title: const Text('Finish class')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('After class · almost done',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),

              // Session info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFF0C080), width: 0.5),
                ),
                child: Row(children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppColors.amber, size: 18),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Checked in at '
                          '${checkinTime.hour.toString().padLeft(2, '0')}:'
                          '${checkinTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.amber)),
                      Text('Duration: ${_duration()}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.amber)),
                    ],
                  ),
                  const Spacer(),
                  _badge('Active', AppColors.amberLight, AppColors.amber),
                ]),
              ),
              const SizedBox(height: 16),

              // GPS
              _gpsCard(),
              const SizedBox(height: 20),

              // QR scan again
              _sectionLabel('SCAN QR CODE AGAIN'),
              const SizedBox(height: 8),
              _qrCard(),
              const SizedBox(height: 20),

              // What I learned
              _sectionLabel('WHAT I LEARNED TODAY'),
              const SizedBox(height: 8),
              TextField(
                controller: _learnedCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Briefly summarize what you learned...',
                ),
              ),
              const SizedBox(height: 14),

              // Feedback
              _sectionLabel('FEEDBACK FOR INSTRUCTOR'),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Suggestions, comments, or questions...',
                ),
              ),
              const SizedBox(height: 28),

              // Finish button
              ElevatedButton(
                onPressed: _loading ? null : _finishClass,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Finish class'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gpsCard() {
    final hasGps = _position != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: hasGps ? AppColors.greenLight : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(
            hasGps
                ? Icons.location_on_rounded
                : Icons.location_searching_rounded,
            color: hasGps ? AppColors.greenMid : AppColors.textTertiary,
            size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            hasGps
                ? '${_position!.latitude.toStringAsFixed(4)}° N, '
                    '${_position!.longitude.toStringAsFixed(4)}° E · captured'
                : 'Getting GPS location...',
            style: TextStyle(
                fontSize: 12,
                color: hasGps ? AppColors.green : AppColors.textTertiary),
          ),
        ),
        if (!hasGps)
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.textTertiary)),
      ]),
    );
  }

  Widget _qrCard() {
    return GestureDetector(
      onTap: () => setState(() => _scannerOpen = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _qrResult != null ? AppColors.greenMid : AppColors.border,
            width: _qrResult != null ? 1.5 : 0.5,
          ),
        ),
        child: Column(children: [
          Icon(
              _qrResult != null
                  ? Icons.check_circle_rounded
                  : Icons.qr_code_scanner_rounded,
              size: 40,
              color: _qrResult != null
                  ? AppColors.greenMid
                  : AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            _qrResult != null
                ? 'QR scanned: $_qrResult'
                : 'Tap to scan QR code again',
            style: TextStyle(
                fontSize: 12,
                color: _qrResult != null
                    ? AppColors.green
                    : AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  Widget _buildScanner() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: BackButton(
            onPressed: () => setState(() => _scannerOpen = false)),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.firstOrNull;
          if (barcode?.rawValue != null) {
            setState(() {
              _qrResult = barcode!.rawValue;
              _scannerOpen = false;
            });
          }
        },
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
      );

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
          letterSpacing: 0.5));
}
