import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../db/database_helper.dart';
import 'finish_screen.dart';

class CheckinScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  const CheckinScreen(
      {super.key, required this.studentId, required this.studentName});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  Position? _position;
  String? _qrResult;
  bool _scannerOpen = false;
  int _moodScore = 3;
  bool _loading = false;

  final _prevTopicCtrl = TextEditingController();
  final _expectedTopicCtrl = TextEditingController();

  final List<String> _moodEmoji = ['😡', '🙁', '😐', '🙂', '😄'];
  final List<String> _moodLabels = ['Very negative', 'Negative', 'Neutral', 'Positive', 'Very positive'];

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
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _position = pos);
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _submitCheckin() async {
    if (_position == null) {
      _snack('Waiting for GPS location...');
      return;
    }
    if (_qrResult == null) {
      _snack('Please scan the class QR code');
      return;
    }
    if (_prevTopicCtrl.text.isEmpty || _expectedTopicCtrl.text.isEmpty) {
      _snack('Please fill in both topic fields');
      return;
    }

    setState(() => _loading = true);
    final session = SessionRecord(
      id: const Uuid().v4(),
      studentId: widget.studentId,
      studentName: widget.studentName,
      checkinLat: _position!.latitude,
      checkinLng: _position!.longitude,
      checkinTime: DateTime.now().toIso8601String(),
      qrCodeData: _qrResult!,
      previousTopic: _prevTopicCtrl.text.trim(),
      expectedTopic: _expectedTopicCtrl.text.trim(),
      moodScore: _moodScore,
    );

    await DatabaseHelper.instance.insertSession(session);
    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Check-in successful!'),
          backgroundColor: AppColors.greenMid),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => FinishScreen(session: session)),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openScanner() {
    setState(() => _scannerOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_scannerOpen) return _buildScanner();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Before class',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),

              // GPS Status
              _gpsCard(),
              const SizedBox(height: 20),

              // QR Code
              _sectionLabel('SCAN CLASS QR CODE'),
              const SizedBox(height: 8),
              _qrCard(),
              const SizedBox(height: 20),

              // Reflection
              _sectionLabel('REFLECTION'),
              const SizedBox(height: 8),
              TextField(
                controller: _prevTopicCtrl,
                decoration: const InputDecoration(
                  hintText: 'What was covered in the previous class?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _expectedTopicCtrl,
                decoration: const InputDecoration(
                  hintText: 'What do you expect to learn today?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Mood
              _sectionLabel('MOOD BEFORE CLASS'),
              const SizedBox(height: 10),
              _moodSelector(),
              const SizedBox(height: 8),
              Center(
                child: Text(_moodLabels[_moodScore - 1],
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _loading ? null : _submitCheckin,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Submit check-in'),
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
                  strokeWidth: 1.5, color: AppColors.textTertiary)),
      ]),
    );
  }

  Widget _qrCard() {
    return GestureDetector(
      onTap: _openScanner,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _qrResult != null ? AppColors.greenMid : AppColors.border,
            width: _qrResult != null ? 1.5 : 0.5,
            style: BorderStyle.solid,
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
                : 'Tap to scan class QR code',
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

  Widget _moodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final score = i + 1;
        final selected = _moodScore == score;
        return GestureDetector(
          onTap: () => setState(() => _moodScore = score),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? AppColors.blueLight : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.blueMid : AppColors.border,
                width: selected ? 1.5 : 0.5,
              ),
            ),
            child: Center(
              child: Text(_moodEmoji[i], style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
      }),
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

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
          letterSpacing: 0.5));
}
