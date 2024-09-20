import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';

class MiniPlayerView extends ConsumerStatefulWidget {
  final MusicLibraryService? service = MusicLibraryService.spotify;

  const MiniPlayerView({
    super.key,
  });

  @override
  _MiniPlayerViewState createState() => _MiniPlayerViewState();
}

class _MiniPlayerViewState extends ConsumerState<MiniPlayerView>
    with TickerProviderStateMixin {
  bool insideEventHandler = false;
  double marqueeVelocity = 25;
  double _leftPosition = 0.0;
  bool _isSwiped = false;

  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  late AnimationController _returnController;
  late Animation<double> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _returnController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _swipeAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_swipeController);
    _returnAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_returnController);

    _swipeController.addListener(() {
      setState(() {
        _leftPosition = _swipeAnimation.value;
      });
    });

    _returnController.addListener(() {
      setState(() {
        _leftPosition = _returnAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _returnController.dispose();
    super.dispose();
  }

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

    if (playbackState.isRepeatMode) {
      if (playbackState.currentProgress!.inMilliseconds >=
          trackLength.inMilliseconds) {
        setState(() {
          _seek(seek: 0);
        });
      }
    }

    if (!playbackState.paused! &&
        !playbackState.isRepeatMode &&
        playbackState.currentProgress!.inMilliseconds >=
            trackLength.inMilliseconds) {
      setState(() {
        _playNextTrack();
      });
    }

    return Container(
      height: 70.0,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 0),
            left: _leftPosition,
            bottom: 0.0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _leftPosition += details.delta.dx;
                });
              },
              onHorizontalDragEnd: (details) async {
                if (details.primaryVelocity!.abs() < 500) {
                  // If velocity is below threshold, return to center
                  _returnAnimation = Tween<double>(
                    begin: _leftPosition,
                    end: 0.0,
                  ).animate(_returnController);
                  _returnController.forward(from: 0.0);
                } else {
                  // Determine swipe direction and trigger staggered animation
                  if (details.primaryVelocity! > 0) {
                    // Swiped right

                    _swipeAnimation = Tween<double>(
                      begin: _leftPosition,
                      end: MediaQuery.of(context).size.width,
                    ).animate(_swipeController);
                    _swipeController.forward(from: 0.0);
                    await _playNextTrack();
                    Future.delayed(Duration(milliseconds: 300), () {
                      _returnAnimation = Tween<double>(
                        begin: -MediaQuery.of(context).size.width,
                        end: 0.0,
                      ).animate(_returnController);
                      _returnController.forward(from: 0.0);
                    });
                  } else {
                    // Swiped left
                    _swipeAnimation = Tween<double>(
                      begin: _leftPosition,
                      end: -MediaQuery.of(context).size.width,
                    ).animate(_swipeController);
                    _swipeController.forward(from: 0.0);
                    await _playPrevTrack();
                    Future.delayed(Duration(milliseconds: 300), () {
                      _returnAnimation = Tween<double>(
                        begin: MediaQuery.of(context).size.width,
                        end: 0.0,
                      ).animate(_returnController);
                      _returnController.forward(from: 0.0);
                    });
                  }
                }
              },
              child: GestureDetector(
                  onTap: () {
                    ref.read(miniPlayerVisibilityProvider.notifier).state =
                        false;
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 70.0,
                        maxHeight: 70.0,
                        minWidth: MediaQuery.of(context).size.width,
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
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
                                    currentSong.songImage ??
                                        currentSong.albumImage!,
                                    width: 40.0,
                                    height: 40.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 20.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    if (!insideEventHandler) {
                                      setState(() {
                                        insideEventHandler = true;
                                      });

                                      if (playbackState.paused!) {
                                        if (playbackState.currentProgress!
                                                .inMilliseconds >=
                                            trackLength.inMilliseconds) {
                                          if (playbackState.isRepeatMode) {
                                            await _seek(seek: 0);
                                          } else {
                                            await _playNextTrack();
                                          }
                                        } else {
                                          await _playSong(
                                              position: playBack.currentProgress
                                                  .inMilliseconds);
                                        }
                                      } else {
                                        bool? r = await ref.read(playbackProvider).pauseTrack();
                                        if (r == false) {
                                          ShowSnackBar.showSnackbarError(
                                              context, 'Error pausing song', 5);
                                        }
                                      }
                                      setState(() {
                                        insideEventHandler = false;
                                      });
                                    }

                                    // var x = await SpotifyService().getAvailableDevices();
                                    // print(x);
                                  },
                                ),
                                if (playbackState.inTrackClipPlaybackMode ==
                                    false)
                                  IconButton(
                                      onPressed: () {
                                        if (insideEventHandler) {
                                          return;
                                        }

                                        Map<String, String> map = {
                                          'fromMiniPlayer': 'true'
                                        };
                                        context.pushNamed('clipEditor',
                                            queryParameters: map);

                                        ref
                                            .read(miniPlayerVisibilityProvider
                                                .notifier)
                                            .state = false;
                                      },
                                      icon: Icon(
                                        Icons.cut,
                                        color: Colors.white,
                                        size: 16,
                                      )),
                                if (playbackState.inTrackClipPlaybackMode ==
                                    true)
                                  IconButton(
                                      onPressed: () async {
                                        if (insideEventHandler) {
                                          return;
                                        }
                                        setState(() {
                                          insideEventHandler = true;
                                        });
                                        await _seek(seek: 0);
                                        setState(() {
                                        insideEventHandler = false;
                                      });
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      )),
                              ],
                            ),
                            ProgressBar(
                              progress: ref
                                  .read(playbackProvider)
                                  .playbackState
                                  .currentProgress!,
                              total: trackLength,
                              onSeek: (duration) async {
                                if (!insideEventHandler) {
                                  setState(() {
                                    insideEventHandler = true;
                                  });

                                  if (playbackState.paused!) {
                                    setState(() {
                                      playBack.playbackState.currentProgress =
                                          duration;
                                      playBack.timer.currentProgress = duration;
                                    });
                                  } else if (playbackState
                                          .currentProgress!.inMilliseconds >=
                                      trackLength.inMilliseconds) {
                                    await _playNextTrack();
                                  } else {
                                    await _seek(seek: duration.inMilliseconds);
                                  }
                                  setState(() {
                                    insideEventHandler = false;
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
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playSong({int? position}) async {
    Response? r = await ref.watch(playbackProvider).playCurrentTrack(position);
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        _showError(response);
      }
    }
  }

  Future<void> _seek({required int seek}) async {
    Response? r = await ref.read(playbackProvider).seekCurrentTrack(seek);
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        _showError(response);
      }
    }
  }

  Future<void> _playNextTrack() async {
    Response? r = await ref.watch(playbackProvider).playNextTrack();
    
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        _showError(response);
      }
    } else {
      ref.read(playbackProvider).setImagePalette();
    }
  }

  Future<void> _playPrevTrack() async {
    Response? r = await ref.watch(playbackProvider).playPreviousTrack();
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        _showError(response);
      }
    } else {
      ref.read(playbackProvider).setImagePalette();
    }
  }

  void _showError(Response r) async {
     ShowSnackBar.showSnackbarError(context, r.body, 3, miniPlayerVisibility: ref.read(miniPlayerVisibilityProvider));
  }
}
