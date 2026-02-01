import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../data/models/mission_model.dart';

class CreateMissionScreen extends ConsumerStatefulWidget {
  const CreateMissionScreen({super.key});
  @override
  ConsumerState<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends ConsumerState<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String _difficulty = 'easy';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _durationMinutes = 120;
  int _maxParticipants = 30;
  Uint8List? _missionImage;
  bool _isSubmitting = false;
  bool _isGeneratingDescription = false;
  String _selectedRegion = 'Michigan';

  // Selected location
  Map<String, dynamic>? _selectedLocation;

  List<Map<String, dynamic>> get _filteredLocations {
    return AppConstants.demoLocations.where((loc) => loc['region'] == _selectedRegion).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Mission')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Mission Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  image: _missionImage != null
                      ? DecorationImage(image: MemoryImage(_missionImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _missionImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          const Text('Add Mission Photo', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                          const Text('(Optional)', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _missionImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Mission Title *',
                hintText: 'e.g., Grand Haven Beach Cleanup',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Description with AI Generate
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe your cleanup event...',
                prefixIcon: const Icon(Icons.description),
                suffixIcon: IconButton(
                  icon: _isGeneratingDescription
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome, color: AppColors.primary),
                  onPressed: _isGeneratingDescription ? null : _generateDescription,
                  tooltip: 'Generate with AI',
                ),
              ),
              maxLines: 4,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Region Selection
            const Text('Region', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                _RegionChip(label: 'Michigan', isSelected: _selectedRegion == 'Michigan', onTap: () => setState(() { _selectedRegion = 'Michigan'; _selectedLocation = null; _addressController.clear(); })),
                const SizedBox(width: 8),
                _RegionChip(label: 'California', isSelected: _selectedRegion == 'California', onTap: () => setState(() { _selectedRegion = 'California'; _selectedLocation = null; _addressController.clear(); })),
              ],
            ),
            const SizedBox(height: 16),

            // Location Selection - FIXED: Proper text colors
            const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filteredLocations.map((loc) {
                final isSelected = _selectedLocation == loc;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLocation = isSelected ? null : loc;
                      if (!isSelected) _addressController.text = loc['address'] as String;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.muted,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      loc['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary, // FIXED: Dark text when not selected
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                hintText: 'Or enter custom address',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),

            // Date & Time Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Time', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Difficulty Selection
            const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _DifficultyOption(label: 'Easy', value: 'easy', selected: _difficulty, onTap: (v) => setState(() => _difficulty = v)),
                const SizedBox(width: 8),
                _DifficultyOption(label: 'Medium', value: 'medium', selected: _difficulty, onTap: (v) => setState(() => _difficulty = v)),
                const SizedBox(width: 8),
                _DifficultyOption(label: 'Hard', value: 'hard', selected: _difficulty, onTap: (v) => setState(() => _difficulty = v)),
              ],
            ),
            const SizedBox(height: 24),

            // Duration Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Duration', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_durationMinutes ~/ 60}h ${_durationMinutes % 60}m', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _durationMinutes.toDouble(),
              min: 30,
              max: 480,
              divisions: 15,
              onChanged: (v) => setState(() => _durationMinutes = v.toInt()),
            ),

            // Max Participants Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Max Participants', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('$_maxParticipants', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _maxParticipants.toDouble(),
              min: 5,
              max: 200,
              divisions: 39,
              onChanged: (v) => setState(() => _maxParticipants = v.toInt()),
            ),
            const SizedBox(height: 16),

            // Rewards Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text('${XpCalculator.calculateXp(_difficulty)} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text('Reward', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Container(width: 1, height: 50, color: Colors.white24),
                  Column(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text('${XpCalculator.calculateCoins(_difficulty)} Coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text('Reward', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Mission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() => _missionImage = bytes);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _generateDescription() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title first')));
      return;
    }

    setState(() => _isGeneratingDescription = true);
    try {
      final description = await ref.read(geminiServiceProvider).generateMissionDescription(
        title: _titleController.text,
        difficulty: _difficulty,
        location: _addressController.text.isNotEmpty ? _addressController.text : '$_selectedRegion beach location',
        duration: _durationMinutes,
      );
      _descriptionController.text = description;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isGeneratingDescription = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(userProvider);
      if (user == null) throw Exception('Not logged in');

      final firebase = ref.read(firebaseServiceProvider);

      // Upload image if present
      String? imageUrl;
      if (_missionImage != null) {
        imageUrl = await firebase.uploadMissionImage(DateTime.now().millisecondsSinceEpoch.toString(), _missionImage!);
      }

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final mission = MissionModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        organizationId: user.uid,
        organizationName: user.organizationName ?? user.name,
        latitude: _selectedLocation?['lat'] ?? (_selectedRegion == 'Michigan' ? 43.0567 : 34.0195),
        longitude: _selectedLocation?['lng'] ?? (_selectedRegion == 'Michigan' ? -86.2556 : -118.4912),
        address: _addressController.text.trim(),
        dateTime: dateTime,
        durationMinutes: _durationMinutes,
        createdAt: DateTime.now(),
        difficulty: _difficulty,
        status: 'upcoming',
        xpReward: XpCalculator.calculateXp(_difficulty),
        coinReward: XpCalculator.calculateCoins(_difficulty),
        imageUrl: imageUrl,
        maxParticipants: _maxParticipants,
        qrCode: 'tideup_mission_${DateTime.now().millisecondsSinceEpoch}',
      );

      await firebase.createMission(mission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission created! 🎉'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: isSelected ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onTap;

  const _DifficultyOption({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    Color color;
    switch (value) {
      case 'easy': color = AppColors.difficultyEasy; break;
      case 'hard': color = AppColors.difficultyHard; break;
      default: color = AppColors.difficultyMedium;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: isSelected ? 2 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
