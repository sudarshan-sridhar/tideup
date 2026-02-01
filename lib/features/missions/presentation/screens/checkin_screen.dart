import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../data/models/checkin_model.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final String missionId;
  const CheckInScreen({super.key, required this.missionId});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  Uint8List? _beforeImage;
  Uint8List? _afterImage;
  bool _isVerifying = false;
  bool _isSubmitting = false;
  bool _qrVerified = false;
  String? _verificationFeedback;
  double? _confidenceScore;
  List<String>? _trashTypes;
  double? _estimatedKg;

  @override
  Widget build(BuildContext context) {
    final mission = ref.watch(missionStreamProvider(widget.missionId)).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        actions: [
          if (!_qrVerified)
            TextButton.icon(
              onPressed: _showQrScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mission Info Card
          if (mission != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.waves, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mission.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(mission.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // QR Verification Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _qrVerified ? AppColors.successLight : AppColors.muted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _qrVerified ? AppColors.success : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  _qrVerified ? Icons.check_circle : Icons.qr_code,
                  color: _qrVerified ? AppColors.success : AppColors.textSecondary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _qrVerified ? 'Location Verified ✓' : 'Step 1: Scan QR Code',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _qrVerified ? AppColors.success : AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _qrVerified ? 'You are at the cleanup location' : 'Scan the QR code at the event location',
                        style: TextStyle(color: _qrVerified ? AppColors.success : AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (!_qrVerified)
                  ElevatedButton(
                    onPressed: _showQrScanner,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Scan'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Photo Upload Section
          const Text('Step 2: Upload Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Take before and after photos of your cleanup area', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _PhotoCard(label: 'Before', image: _beforeImage, onTap: () => _pickImage(true))),
              const SizedBox(width: 12),
              Expanded(child: _PhotoCard(label: 'After', image: _afterImage, onTap: () => _pickImage(false))),
            ],
          ),
          const SizedBox(height: 24),

          // AI Verification Button
          if (_beforeImage != null && _afterImage != null && _confidenceScore == null)
            OutlinedButton.icon(
              onPressed: _isVerifying ? null : _verifyWithAi,
              icon: _isVerifying
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isVerifying ? 'Analyzing...' : 'Verify with AI'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),

          // AI Analysis Result
          if (_confidenceScore != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _confidenceScore! >= 0.7 ? AppColors.successLight : AppColors.warningLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _confidenceScore! >= 0.7 ? AppColors.success : AppColors.warning),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: _confidenceScore! >= 0.7 ? AppColors.success : AppColors.warning),
                      const SizedBox(width: 8),
                      const Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _confidenceScore! >= 0.7 ? AppColors.success : AppColors.warning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(_confidenceScore! * 100).toInt()}% confident',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_trashTypes != null && _trashTypes!.isNotEmpty)
                    Text('Trash found: ${_trashTypes!.join(', ')}', style: const TextStyle(fontSize: 13)),
                  if (_estimatedKg != null)
                    Text('Estimated: ${_estimatedKg!.toStringAsFixed(1)} kg collected', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(_verificationFeedback ?? '', style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _canSubmit() ? _submit : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSubmitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Check-In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),

          // Skip QR for demo
          if (!_qrVerified)
            TextButton(
              onPressed: () => setState(() => _qrVerified = true),
              child: const Text('Skip QR (Demo Mode)', style: TextStyle(color: AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _qrVerified && _beforeImage != null && _afterImage != null && !_isSubmitting;
  }

  Future<void> _pickImage(bool isBefore) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source == null) return;

    final image = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      if (isBefore) {
        _beforeImage = bytes;
      } else {
        _afterImage = bytes;
      }
      _confidenceScore = null;
      _trashTypes = null;
      _estimatedKg = null;
      _verificationFeedback = null;
    });
  }

  Future<void> _showQrScanner() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _QrScannerScreen(missionId: widget.missionId)),
    );
    if (result == true) {
      setState(() => _qrVerified = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location verified! ✓'), backgroundColor: AppColors.success),
        );
      }
    }
  }

  Future<void> _verifyWithAi() async {
    if (_beforeImage == null || _afterImage == null) return;

    setState(() => _isVerifying = true);
    try {
      final result = await ref.read(geminiServiceProvider).verifyCleanup(
        beforePhoto: _beforeImage!,
        afterPhoto: _afterImage!,
      );
      setState(() {
        _confidenceScore = result.confidenceScore;
        _verificationFeedback = result.feedback;
        _trashTypes = result.trashTypes;
        _estimatedKg = result.estimatedTrashKg;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI verification failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(userProvider);
      final mission = ref.read(missionStreamProvider(widget.missionId)).value;
      if (user == null || mission == null) throw Exception('Not logged in or mission not found');

      final firebase = ref.read(firebaseServiceProvider);

      // Upload images
      final checkInId = DateTime.now().millisecondsSinceEpoch.toString();
      final beforeUrl = await firebase.uploadCleanupProof(checkInId, 'before', _beforeImage!);
      final afterUrl = await firebase.uploadCleanupProof(checkInId, 'after', _afterImage!);

      // Determine status based on AI confidence
      final status = _confidenceScore != null && _confidenceScore! >= 0.85 ? 'verified' : 'pending';

      // Create check-in
      final checkIn = CheckInModel(
        id: '',
        missionId: widget.missionId,
        missionTitle: mission.title,
        userId: user.uid,
        userName: user.name,
        checkInTime: DateTime.now(),
        status: status,
        beforePhotoUrl: beforeUrl,
        afterPhotoUrl: afterUrl,
        aiVerified: _confidenceScore != null && _confidenceScore! >= 0.85,
        aiConfidenceScore: _confidenceScore,
        aiAnalysis: _verificationFeedback,
        detectedTrashTypes: _trashTypes,
        estimatedTrashKg: _estimatedKg,
      );

      await firebase.createCheckIn(checkIn);

      // Auto-approve if high confidence
      if (status == 'verified') {
        await firebase.updateUserStats(
          uid: user.uid,
          xpToAdd: mission.xpReward,
          coinsToAdd: mission.coinReward,
          trashKgToAdd: _estimatedKg,
          missionId: widget.missionId,
          completed: true,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'verified'
                ? 'Check-in verified! Rewards added 🎉'
                : 'Check-in submitted for review'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

class _PhotoCard extends StatelessWidget {
  final String label;
  final Uint8List? image;
  final VoidCallback onTap;

  const _PhotoCard({required this.label, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: image != null ? null : AppColors.muted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: image != null ? AppColors.success : AppColors.border, width: image != null ? 2 : 1),
          image: image != null ? DecorationImage(image: MemoryImage(image!), fit: BoxFit.cover) : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 36, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: AppColors.success, size: 16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _QrScannerScreen extends StatefulWidget {
  final String missionId;
  const _QrScannerScreen({required this.missionId});

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_scanned) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final value = barcode.rawValue;
                if (value != null && value.contains(widget.missionId)) {
                  _scanned = true;
                  Navigator.pop(context, true);
                  return;
                }
              }
              // For demo: accept any QR code
              if (barcodes.isNotEmpty) {
                _scanned = true;
                Navigator.pop(context, true);
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text('Point your camera at the QR code', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Skip (Demo Mode)', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
