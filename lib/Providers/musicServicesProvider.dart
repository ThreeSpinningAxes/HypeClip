import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Services/UserService.dart';

final musicServicesProvider = StateNotifierProvider<MusicServicesNotifier, Set<MusicLibraryService>>((ref) {
  return MusicServicesNotifier();
});

class MusicServicesNotifier extends StateNotifier<Set<MusicLibraryService>> {
  MusicServicesNotifier() : super(Userservice.getConnectedMusicLibraries());

  void updateMusicServices() {
    state = Userservice.getConnectedMusicLibraries();
  }
}