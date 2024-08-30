import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/ErrorPages/GenericErrorPage.dart';
import 'package:hypeclip/Pages/SongPlayer/SongPlayback.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:marquee/marquee.dart';

class MiniPlayerView extends ConsumerStatefulWidget {
  final MusicLibraryService? service = MusicLibraryService.spotify;

  const MiniPlayerView({
    Key? key,
  }) : super(key: key);

  @override
  _MiniPlayerViewState createState() => _MiniPlayerViewState();
}

class _MiniPlayerViewState extends ConsumerState<MiniPlayerView> {
  bool insideEvenHandler = false;
  double marqueeVelocity = 25;

  @override
  Widget build(BuildContext context) {
    final bool miniPlayerVisibility = ref.watch(miniPlayerVisibilityProvider);
    marqueeVelocity = 25;
    if (!miniPlayerVisibility) {
      return SizedBox.shrink();
    }
    final playBack = ref.watch(playbackProvider);
    final PlaybackState playbackState =
        ref.watch(playbackProvider).playbackState;

    final bool inTrackClipPlaybackMode =
        ref.watch(playbackProvider).playbackState.inTrackClipPlaybackMode!;

    Song currentSong;
    final Duration trackLength;
    String trackName;

    if (playBack.playbackState.inTrackClipPlaybackMode ?? false) {
      currentSong = playBack.playbackState.currentTrackClip!.song;
      trackLength = playBack.playbackState.currentTrackClip!.clipLength!;
      trackName = playBack.playbackState.currentTrackClip!.clipName;
    } else {
      currentSong = playBack.playbackState.currentSong!;
      trackLength = playBack.playbackState.currentSong!.duration!;
      trackName = playBack.playbackState.currentSong!.songName!;
    }

    if (playbackState.currentProgress!.inMilliseconds >= trackLength.inMilliseconds) {
      _playNextTrack();
    }

    return GestureDetector(
        onTap: () {
          ref.read(miniPlayerVisibilityProvider.notifier).state = false;
          context.pushNamed('songPlayer');
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation, secondaryAnimation) =>
          //         Scaffold(key: context.widget.key, body: SongPlayback(),),
          //     transitionsBuilder:
          //         (context, animation, secondaryAnimation, child) {
          //       return FadeTransition(
          //         opacity: animation,
          //         child: child,
          //       );
          //     },
          //   ),
          // );
        },
        child: Hero(
          tag: 'miniPlayer',
          child: Container(
            height: 70.0,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Card(
              //margin: EdgeInsets.only(left: 10, right: 10),
              color: playbackState.domColorLinGradient?.colors[0],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Album Image
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Image.network(
                          currentSong.songImage ?? currentSong.albumImage!,
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SizedBox(
                            //   height: 20, // Set a fixed height
                            //   child: Marquee(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     textDirection: TextDirection.ltr,
                            //     text: "${currentSong.songName!} | ${currentSong.artistName!}",
                            //     numberOfRounds: 3,
                            //     onDone: () {
                            //       marqueeVelocity *= -1;
                            //     },
                            //     velocity: marqueeVelocity,
                            //     pauseAfterRound: Duration(seconds: 1),
                            //     startAfter: Duration(seconds: 1),

                            //     style: TextStyle(
                            //       fontSize: 14,

                            //       color: Colors.white,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),

                            Text(
                              trackName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              currentSong.artistName!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Song Name and Artist

                      // Play/Pause Button

                      IconButton(
                        icon: Icon(
                          playbackState.paused!
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (!insideEvenHandler) {
                            setState(() {
                              insideEvenHandler = true;
                            });

                            if (playbackState.paused!) {
                              if (playBack.timer.trackFinished) {
                                await _playSong(position: 0);
                              } else {
                                await _playSong(
                                    position: playBack
                                        .timer.currentProgress.inMilliseconds);
                              }
                            } else {
                              bool? r = await playBack.pauseTrack();
                              if (r == false) {
                                ShowSnackBar.showSnackbarError(
                                    context, 'Error pausing song', 5);
                              }
                            }
                            setState(() {
                              insideEvenHandler = false;
                            });
                          }

                          // var x = await SpotifyService().getAvailableDevices();
                          // print(x);
                        },
                      ),
                      IconButton(
                          onPressed: () {
                            Map<String, String> map = {
                              'fromMiniPlayer': 'true'
                            };
                            context.pushNamed('clipEditor',
                                queryParameters: map);

                            ref
                                .read(miniPlayerVisibilityProvider.notifier)
                                .state = false;
                          },
                          icon: Icon(
                            Icons.cut,
                            color: Colors.white,
                            size: 16,
                          )),
                    ],
                  ),
                  ProgressBar(
                    progress: playbackState.currentProgress!,
                    total: trackLength,
                    onSeek: (duration) async {
                      if (!insideEvenHandler) {
                        setState(() {
                          insideEvenHandler = true;
                        });

                        await _seek(seek: duration.inMilliseconds);
                        setState(() {
                          insideEvenHandler = false;
                        });
                      }
                    },
                    baseBarColor: Colors.black,
                    progressBarColor: Colors.white,
                    thumbColor: Colors.white,
                    thumbRadius: 3.0,
                    timeLabelLocation: TimeLabelLocation.none,
                    barHeight: 3.0,
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _playSong({int? position}) async {
    Response? r = await ref.watch(playbackProvider).playCurrentTrack(position);
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        setState(() {
          //error
        });
      }
    }
  }

  Future<void> _seek({required int seek}) async {
    Response? r = await ref.read(playbackProvider).seekCurrentTrack(seek);
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        setState(() {
          //error
        });
      }
    }
  }


  Future<void> _playNextTrack() async {
    Response? r = await ref.watch(playbackProvider).playNextTrack();
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        setState(() {
          //error
        });
      }
    }
  }
  Future<void> _playPrevTrack() async {
    Response? r = await ref.watch(playbackProvider).playNextTrack();
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        setState(() {
          //error
        });
      }
    }
  }
}
