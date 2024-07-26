

class Playlist {
  String id;
  String? uri;
  String name;
  String? ownerName;
  String? imageUrl;
  int? totalTracks;
  


  Playlist({
    required this.id,
    this.uri,
    required this.name,
    this.ownerName,
    this.imageUrl,
    this.totalTracks,
  });
}