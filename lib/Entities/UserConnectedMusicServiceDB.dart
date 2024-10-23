import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Entities/UserProfileDB.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:objectbox/objectbox.dart';


@Entity()
class UserConnectedMusicService  {

  @Id()
  int id = 0;

  @Transient()
  MusicLibraryService? service;

  String get musicLibraryServiceDB => service!.name;
  set musicLibraryServiceDB(String value) => service = MusicLibraryService.values.firstWhere((e) => e.name == value, orElse: () => MusicLibraryService.unknown);

  String? accessToken = "";

  String? refreshToken = "" ;

  final userPlaylistsDB = ToMany<Playlist>();

  final connectedUserDB = ToOne<UserProfileDB>();


}
