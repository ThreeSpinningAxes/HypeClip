import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClip.dart';

class TrackListTile extends StatelessWidget {
  final Widget? trailing;
  final TrackClip? trackClip;
  final Song? song;
  final VoidCallback? onTap;
  final Color? backgroundColor;

const TrackListTile( {this.onTap, super.key, this.trailing, this.trackClip, this.song, this.backgroundColor
});

  @override
  Widget build(BuildContext context) {
    Widget leading;
    String title;
    String artist;


    if (song != null) {
      leading = song!.albumImage != null
          ? FadeInImage.assetNetwork(
              placeholder:
                  'assets/loading_placeholder.gif', // Path to your placeholder image
              image: song!.albumImage!,
              fit: BoxFit.cover,
              width: 50.0, // Adjust the width as needed
              height: 50.0, // Adjust the height as needed
            )
          : Icon(Icons.music_note, color: Colors.white);
      title = song!.songName ?? 'Unknown';
      artist = song!.artistName ?? 'Unknown';
    }
    else if (trackClip != null) {
      leading = trackClip!.song.albumImage != null
          ? FadeInImage.assetNetwork(
              placeholder:
                  'assets/loading_placeholder.gif', // Path to your placeholder image
              image: trackClip!.song.albumImage!,
              fit: BoxFit.cover,
              width: 50.0, // Adjust the width as needed
              height: 50.0, // Adjust the height as needed
            )
          : Icon(Icons.music_note, color: Colors.white);
      title = trackClip!.clipName;
      artist = trackClip!.song.artistName!;
    }
    else {
      leading = Icon(Icons.music_note, color: Colors.white);
      title = 'Unknown';
      artist = 'Unknown';
    }
    
    return ListTile(
                            trailing: trailing,
                            leading: leading,

                            onTap: onTap,
                            title: Text(title,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors
                                        .white)), // Adjust according to your data structure
                            subtitle: Text(artist,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                            tileColor: backgroundColor,
                          );
  }
}