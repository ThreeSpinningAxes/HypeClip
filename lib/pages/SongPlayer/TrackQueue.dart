import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Widgets/TrackListTile.dart';

class TrackQueue extends ConsumerStatefulWidget {
  const TrackQueue({super.key});

  @override
  _TrackQueueState createState() => _TrackQueueState();
}

class _TrackQueueState extends ConsumerState<TrackQueue> {
  @override
  Widget build(BuildContext context) {
    final PlaybackNotifier playback = ref.watch(playbackProvider.notifier);
    final bool inTrackClipPlaybackMode =
        playback.playbackState.inTrackClipPlaybackMode!;
    final Duration trackDuration;

    List queue = [];
    final TrackClip? currentClip;
    final Song? currentSong;
    if (inTrackClipPlaybackMode) {
      currentClip = playback.playbackState.currentTrackClip;
      currentSong = playback.playbackState.currentTrackClip!.song;
      double t = playback.playbackState.currentTrackClip!.clipPoints[1] - playback.playbackState.currentTrackClip!.clipPoints[0];
      
      trackDuration = Duration(milliseconds: t.toInt());
      queue = List<TrackClip>.from(playback.playbackState.trackClipQueue!);
    } else {
      currentClip = null;
      currentSong = playback.playbackState.currentSong;
      trackDuration =playback.playbackState.currentSong!.duration!;
      queue = List<Song>.from(playback.playbackState.trackQueue!);
    }

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        title: Text(
          'Current Queue',
          style: const TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (context.mounted && context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Currently playing",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TrackListTile(
                trackClip: currentClip,
                song: currentSong,
                trailing: IconButton(
                    onPressed: () async {
                      PlaybackNotifier playback =
                          ref.watch(playbackProvider.notifier);
                      if (!playback.playbackState.paused!) {
                        await playback.pauseTrack();
                      } else {
                        await _playSong(
                            position: playback
                                .playbackState.currentProgress!.inMilliseconds);
                      }
                    },
                    icon: ref.watch(playbackProvider).playbackState.paused!
                        ? Icon(Icons.play_arrow)
                        : Icon(Icons.pause)),
                    
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ProgressBar(
                  progress: playback.playbackState.currentProgress!,
                  total: trackDuration,
                  baseBarColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            thumbRadius: 0,
                            timeLabelLocation: TimeLabelLocation.none,
                        progressBarColor: Colors.white,
                        
                
                            
                            ),
              ),
              SizedBox(height: 20),
              Text("Queue",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Expanded(
                child: Material(
                  child: ReorderableListView.builder(
                      proxyDecorator: (widget, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          child: widget,
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        ref.read(playbackProvider.notifier).reorderQueue(
                            inTrackClipPlaybackMode, oldIndex, newIndex);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                          key: ValueKey(inTrackClipPlaybackMode ? queue[index].ID : queue[index].trackURI),
                          direction: queue.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
                          onDismissed: (direction) {
                            if (queue.length == 1) {
                              return;
                            }
                            ref
                                .watch(playbackProvider.notifier)
                                .removeItemFromQueue(index);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: TrackListTile(
                            trackClip:
                                inTrackClipPlaybackMode ? queue[index] : null,
                            song:
                                !inTrackClipPlaybackMode ? queue[index] : null,
                            backgroundColor: ref
                                        .read(playbackProvider)
                                        .playbackState
                                        .currentTrackIndex ==
                                    index
                                ? Colors.grey[800]
                                : Theme.of(context).scaffoldBackgroundColor,
                            onTap: () async {
                              await playback.playNewTrackInList(index, updateGradient: true);
                            },
                            trailing: IconButton(
                                icon: Icon(
                                  Icons.cut,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  if (playback
                                          .playbackState.currentTrackIndex! !=
                                      index) {
                                    await playback
                                        .playNewTrackInList(index, updateGradient: true)
                                        .then((value) {});
                                  }
                                  if (context.mounted) {
                                    context.pushNamed('clipEditor');
                                  }
                                }),
                          ),
                        );
                      },
                      itemCount: queue.length,
                      shrinkWrap: true),
                ),
              ),
              SizedBox(height: 70),
            ],
          )),
    );
  }

  Future<void> _playSong({int? position}) async {
    Response? r = await ref.watch(playbackProvider).playCurrentTrack(position);
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        setState(() {
          ShowSnackBar.showSnackbarError(
              context, jsonDecode(response.body)['error']['message'], 5);
        });
      }
    } else {}
  }
}
