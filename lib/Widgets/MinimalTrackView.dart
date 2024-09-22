import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';

class MinimalTrackView extends ConsumerWidget {
final String? imageURL;
  final String trackName;
  final TrackClip? clip;
  final TrackClipPlaylist? playlist;

  const MinimalTrackView(
      {super.key,
      this.imageURL,
      required this.trackName,
      this.clip,
      this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the size based on the constraints
        double imageSize =
            constraints.maxWidth * 0.5; // Adjust the factor as needed

        return GestureDetector(
          onTap: () {
            if (clip != null && playlist != null) {
              ref.read(playbackProvider.notifier).init(PlaybackState(
                  currentProgress: Duration.zero,
                  currentSong: clip!.song,
                  startPosition:
                      Duration(milliseconds: clip!.clipPoints[0].toInt()),
                  paused: true,
                  currentTrackIndex: playlist!.clips!.indexOf(clip!),
                  trackClipPlaylist: playlist,
                  currentTrackClip: clip,
                  inTrackClipPlaybackMode: true,
                  musicLibraryService: clip!.musicLibraryService,
                  isShuffleMode: false,
                  isRepeatMode: false,
                  trackClipQueue: playlist!.clips,
                  originalTrackQueue: playlist!.clips));
              context.pushNamed('songPlayer');
            }
          },
          child: Column(
            children: [
              imageURL != null
                  ? FadeInImage.assetNetwork(
                      placeholder:
                          'assets/loading_placeholder.gif', // Path to your placeholder image
                      image: imageURL!,
                      fit: BoxFit.cover,
                      width: imageSize,
                      height: imageSize,
                    )
                  : SizedBox(
                      height: imageSize,
                      width: imageSize,
                      child: Icon(Icons.music_note, color: Colors.white),
                    ),
              SizedBox(height: 10),
              SizedBox(
                width: imageSize, // Adjust the width as needed
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    trackName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MinimalTrackListView extends ConsumerWidget {
  final String playlistName;
  const MinimalTrackListView({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TrackClip> tracks =
        ref.watch(trackClipProvider)[playlistName]?.clips ?? [];
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 2,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      children: tracks.map((track) {
        return MinimalTrackView(
          imageURL: track.song!.albumImage,
          trackName: track.clipName,
          clip: track,
          playlist: ref.watch(trackClipProvider)[playlistName],
        );
      }).toList(),
    );
  }
}
