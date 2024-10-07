

import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/UserConnectedMusicServiceDB.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Playlist {
  
  @Id()
  int? dbID = 0; 
  
  String id; //actual streaming service id
  String? uri;

  @Index(type: IndexType.value)
  String name;
  String? ownerName;
  String? imageUrl;
  int? totalTracks;
  
  final songsDB = ToMany<Song>();

  final userMusicStreamingServiceAccount = ToOne<UserConnectedMusicService>();

  Playlist({
    this.dbID,
    required this.id,
    this.uri,
    required this.name,
    this.ownerName,
    this.imageUrl,
    this.totalTracks,
  });
}