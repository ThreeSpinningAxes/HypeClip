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
}