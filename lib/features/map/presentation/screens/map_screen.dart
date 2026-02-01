import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../../missions/presentation/screens/mission_detail_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  String? _selectedMissionId;

  // Default to Michigan (Grand Haven)
  static const LatLng _defaultCenter = LatLng(43.0567, -86.2556);

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(missionsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mission Map')),
      body: missionsAsync.when(
        data: (missions) {
          final markers = missions.map((m) => Marker(
            markerId: MarkerId(m.id),
            position: LatLng(m.latitude, m.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              m.difficulty == 'easy' ? BitmapDescriptor.hueGreen :
              m.difficulty == 'hard' ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange,
            ),
            onTap: () => setState(() => _selectedMissionId = m.id),
          )).toSet();

          final selectedMission = _selectedMissionId != null
              ? missions.where((m) => m.id == _selectedMissionId).firstOrNull
              : null;

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(target: _defaultCenter, zoom: 8),
                markers: markers,
                onMapCreated: (controller) => _mapController = controller,
                onTap: (_) => setState(() => _selectedMissionId = null),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              // Mission Preview Card
              if (selectedMission != null)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MissionDetailScreen(missionId: selectedMission.id))),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: BorderRadius.circular(12),
                              image: selectedMission.imageUrl != null
                                  ? DecorationImage(image: NetworkImage(selectedMission.imageUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: selectedMission.imageUrl == null ? const Icon(Icons.waves, color: AppColors.primary) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(selectedMission.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(selectedMission.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    DifficultyBadge(difficulty: selectedMission.difficulty, small: true),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star, size: 14, color: AppColors.xpColor),
                                    Text(' ${selectedMission.xpReward}', style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.monetization_on, size: 14, color: AppColors.coinColor),
                                    Text(' ${selectedMission.coinReward}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              // My Location Button
              Positioned(
                bottom: selectedMission != null ? 140 : 20,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'location',
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    _mapController?.animateCamera(CameraUpdate.newLatLng(_defaultCenter));
                  },
                  child: const Icon(Icons.my_location, color: AppColors.primary),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
