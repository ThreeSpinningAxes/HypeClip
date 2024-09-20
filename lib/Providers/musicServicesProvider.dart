import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Services/UserProfileService.dart';

final musicServicesProvider = StateNotifierProvider<MusicServicesNotifier, Set<MusicLibraryService>>((ref) {
  return MusicServicesNotifier();
});

class MusicServicesNotifier extends StateNotifier<Set<MusicLibraryService>> {
  MusicServicesNotifier() : super(UserProfileService.userProfile.connectedMusicServices);

  void updateMusicServices() {
    state = UserProfileService.getConnectedMusicLibraries();
  }

  bool containsAnyService() {
   
    return state.isNotEmpty;
  }

  void addService(MusicLibraryService service) {
    state.add(service);
  }

  Future<void> deleteMusicService(MusicLibraryService service) async {
    state.remove(service);
    await UserProfileService.deleteMusicService(service);
    state = Set.from(state);
  }

  Future<void> addMusicService(MusicLibraryService service, Map<String, dynamic> data) async {
    state.add(service);
    await UserProfileService.addMusicService(service, data);
    state = Set.from(state);
  }
}