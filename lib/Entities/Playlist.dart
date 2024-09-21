

import 'package:hypeclip/Entities/Song.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Playlist {
  @Id(assignable: true)
  int? dbID; 
  
  String id; //actual streaming service id
  String? uri;
  String name;
  String? ownerName;
  String? imageUrl;
  int? totalTracks;
  
  final songs = ToMany<Song>();

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