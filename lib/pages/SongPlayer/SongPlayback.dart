import 'dart:async';
import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/ErrorPages/GenericErrorPage.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';

class SongPlayback extends ConsumerStatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;
  final bool? inTrackClipPlaybackMode;
  final bool? resetForNewTrack;

  const SongPlayback(
      {super.key, this.inTrackClipPlaybackMode, this.resetForNewTrack});

  @override
  _SongPlaybackState createState() => _SongPlaybackState();
}

class _SongPlaybackState extends ConsumerState<SongPlayback> {
  bool _isLoading = true;
  late final MusicServiceHandler musicServiceHandler;
  bool error = false;
  bool initError = false;
  GenericErrorPage errorPage = GenericErrorPage();

  @override
  void initState() {
    super.initState();
    musicServiceHandler = MusicServiceHandler(service: widget.service);
    PlaybackNotifier playbackNotifier = ref.read(playbackProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isLoading = true;
        playbackNotifier.insideEvent = true;
      });
      _asyncInit().then((value) {
        setState(() {});
      });
      setState(() {
        _isLoading = false;
        playbackNotifier.insideEvent = false;
      });
    });
  }

  void _refresh() async {
    PlaybackNotifier playbackNotifier = ref.read(playbackProvider);
    setState(() {
      _isLoading = true;
      playbackNotifier.insideEvent = true;
    });
    await _asyncInit();
    setState(() {
      _isLoading = false;
      playbackNotifier.insideEvent = false;
    });
  }

  _asyncInit() async {
    Response r = await musicServiceHandler.isStreaingServiceAppOpen();
    if (r.statusCode != 200 && r.statusCode != 204) {
      errorPage = GenericErrorPage(
        errorHeader: "Error with ${widget.service.name.toCapitalized()}",
        errorDescription: jsonDecode(r.body)['error']['message'],
        buttonText: "Retry",
        buttonAction: _refresh,
      );
      setState(() {
        _isLoading = false;
        error = true;
        initError = true;
      });
      return;
    }
    PlaybackState playbackState = ref.read(playbackProvider).playbackState;

    if (widget.resetForNewTrack ?? false) {
      r = await ref.watch(playbackProvider).playTrackAfterInit();
      if (r.statusCode != 200 && r.statusCode != 204) {
        errorPage = GenericErrorPage(
          errorHeader:
              "Failed to play track ${playbackState.currentSong!.songName}",
          errorDescription: jsonDecode(r.body)['error']['message'],
          buttonText: "Retry",
          buttonAction: _refresh,
        );

        setState(() {
          error = true;
          initError = true;
        });
        return;
      }
    }
    setState(() {
      error = false;
      initError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
    if (initError) {
      return errorPage;
    }
    final playBack = ref.watch(playbackProvider);
    final PlaybackState playbackState = playBack.playbackState;
    final String trackName = playbackState.currentTrackName!;
    final int trackDuration = playbackState.trackLength!;
    final String trackArtist = playbackState.currentTrackArtist!;
    final String trackImg = playbackState.currentTrackImg!;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: playbackState.domColorLinGradient,
            color: playbackState.domColorLinGradient == null
                ? Colors.transparent
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      PlaybackNotifier playBack = ref.read(playbackProvider);
                      if (playBack.insideEvent) {
                        return;
                      }
                      if (context.mounted) {
                        context.pop();
                      }

                      if (!error) {
                        ref.read(miniPlayerVisibilityProvider.notifier).state =
                            true;
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        trackImg,
                        height: 300,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 35),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trackName,
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 4),
                              Text(
                                trackArtist,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.repeat),
                            color: playbackState.isRepeatMode
                                ? Color.fromARGB(255, 8, 104, 187)
                                : Colors.white,
                            onPressed: () {
                              PlaybackNotifier playBack =
                                  ref.read(playbackProvider);
                              if (playBack.insideEvent) {
                                return;
                              }
                              playBack.updatePlaybackState(
                                  isRepeatMode: !playbackState.isRepeatMode);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.skip_previous,
                                      color: Colors.white),
                                  onPressed: () async {
                                    PlaybackNotifier playBack =
                                        ref.read(playbackProvider);
                                    if (!playBack.insideEvent) {
                                      playBack.insideEvent = true;
                                      if (playbackState.currentProgress!
                                              .inMilliseconds <=
                                          Duration(seconds: 3).inMilliseconds) {
                                        await _playPreviousSong();
                                      } else if (playbackState.currentProgress!
                                              .inMilliseconds >=
                                          Duration(seconds: 3).inMilliseconds) {
                                        await _seek(seek: 0);
                                      }
                                      playBack.insideEvent = false;
                                    }
                                  }),
                              IconButton(
                                  icon: Icon(
                                      playbackState.paused!
                                          ? Icons.play_arrow
                                          : Icons.pause,
                                      color: Colors.white,
                                      size: 36),
                                  onPressed: () async {
                                    await _pausePlayback(
                                        playbackState.currentSong!,
                                        trackDuration);
                                  }),
                              IconButton(
                                  icon: Icon(Icons.skip_next,
                                      color: Colors.white),
                                  onPressed: () async {
                                    PlaybackNotifier playBack =
                                        ref.read(playbackProvider);
                                    if (!playBack.insideEvent) {
                                      playBack.insideEvent = true;

                                      await _playNextSong();

                                      playBack.insideEvent = false;
                                    }
                                  }),
                            ],
                          ),
                          IconButton(
                              icon: Icon(Icons.shuffle),
                              color: playbackState.isShuffleMode
                                  ? Color.fromARGB(255, 8, 104, 187)
                                  : Colors.white,
                              onPressed: () {
                                PlaybackNotifier playBack =
                                    ref.read(playbackProvider);
                                if (!playBack.insideEvent) {
                                  playBack.insideEvent = true;

                                  if (!playbackState.isShuffleMode) {
                                    playBack.shuffleQueue();
                                  } else {
                                    playBack.undueShuffle();
                                  }
                                  playBack.insideEvent = false;
                                }
                              }),
                        ],
                      ),
                      if (playbackState.inTrackClipPlaybackMode != null &&
                          !playbackState.inTrackClipPlaybackMode!)
                        IconButton(
                            onPressed: () {
                              PlaybackNotifier playBack =
                                  ref.read(playbackProvider);
                              if (playBack.insideEvent) {
                                return;
                              }
                              context.pushNamed('clipEditor');
                            },
                            icon: Icon(
                              Icons.cut,
                              color: Colors.white,
                            )),
                      if (playbackState.inTrackClipPlaybackMode == null ||
                          playbackState.inTrackClipPlaybackMode!)
                        SizedBox(
                          height: 20,
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: ProgressBar(
                          // baseBarColor: Colors.black,
                          progressBarColor: Colors.white,
                          baseBarColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          progress: playBack.playbackState.currentProgress!,
                          //buffered: Duration(milliseconds: 2000),
                          total: Duration(milliseconds: trackDuration),
                          onSeek: (duration) async {
                            PlaybackNotifier playBack =
                                ref.read(playbackProvider);
                            if (playBack.insideEvent) {
                              return;
                            }

                            playBack.insideEvent = true;
                            if (playbackState.paused!) {
                              // setState(() {
                              //   playBack.playbackState.currentProgress =
                              //       duration;
                              // });
                              playBack.updatePlaybackState(
                                  currentProgress: duration);
                            } else if (playbackState
                                    .currentProgress!.inMilliseconds >=
                                trackDuration) {
                              await _playNextSong();
                            } else {
                              await _seek(seek: duration.inMilliseconds);
                            }

                            playBack.insideEvent = false;
                          },
                        ),
                      ),
                      if (playbackState.inTrackClipPlaybackMode!)
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            size: 36,
                          ),
                          color: Colors.white,
                          onPressed: () async {
                            PlaybackNotifier playBack =
                                    ref.read(playbackProvider);
                            if (playBack.insideEvent) {
                              return;
                            }
                            playBack.insideEvent = true;
                            await _seek(seek: 0);
                            playBack.insideEvent = false;
                          },
                        ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          if (playBack.insideEvent) {
                            return;
                          }
                          context.pushNamed('queue');
                        },
                        child: Text(
                          "Queue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playNextSong() async {
    Response r = await ref.read(playbackProvider).playNextTrack();
    if (r.statusCode != 200 && r.statusCode != 204) {
      setState(() {
        ShowSnackBar.showSnackbarError(
            context, jsonDecode(r.body)['error']['message'], 5);
        error = true;
      });
    } else {
      setState(() {
        error = false;
      });

      ref.read(playbackProvider).setImagePalette();

      if (ref.read(playbackProvider).playbackState.inTrackClipPlaybackMode!) {
        ref.read(trackClipProvider.notifier).appendRecentlyListenedToTrack(
            ref.read(playbackProvider).playbackState.currentTrackClip!);
      }
    }
  }

  Future<void> _playPreviousSong() async {
    
    Response r = await ref.read(playbackProvider).playPreviousTrack();
    if (r.statusCode != 200 && r.statusCode != 204) {
      setState(() {
        ShowSnackBar.showSnackbarError(
            context, jsonDecode(r.body)['error']['message'], 5);
        error = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        error = false;
      });

      ref.read(playbackProvider).setImagePalette();
      setState(() {
        _isLoading = false;
      });

      if (ref.read(playbackProvider).playbackState.inTrackClipPlaybackMode!) {
        ref.read(trackClipProvider.notifier).appendRecentlyListenedToTrack(
            ref.read(playbackProvider).playbackState.currentTrackClip!);
      }
    }
  }

  Future<void> _playSong({int? position}) async {
    Response? r = await ref.watch(playbackProvider).playCurrentTrack(position);
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      if (mounted) {
        setState(() {
          ShowSnackBar.showSnackbarError(
              context, jsonDecode(response.body)['error']['message'], 5);
          error = true;
        });
      }
    } else {
      error = false;
    }
  }

  Future<void> _seek({required int seek}) async {
    Response? r = await ref.read(playbackProvider).seekCurrentTrack(seek);
    Response response = r;
    if (response.statusCode != 204 && response.statusCode != 200) {
      setState(() {
        ShowSnackBar.showSnackbarError(
            context, jsonDecode(response.body)['error']['message'], 5);
        error = true;
      });
    } else {
      setState(() {
        error = false;
      });
    }
  }

  Future<void> _pausePlayback(Song currentSong, int trackDuration) async {
    PlaybackNotifier playBack = ref.read(playbackProvider);
    if(playBack.insideEvent) {
      return;
    }
    playBack.insideEvent = true;
      
      PlaybackState playbackState = ref.read(playbackProvider).playbackState;
      if (playbackState.paused!) {
        if (playbackState.currentProgress!.inMilliseconds >= trackDuration) {
          if (playbackState.isRepeatMode) {
            await _seek(seek: 0);
          } else {
            await _playNextSong();
          }
        } else {
          await _playSong(position: playBack.currentProgress.inMilliseconds);
        }
      } else {
        bool? result = await playBack.pauseTrack();
        if (result == false) {
          ShowSnackBar.showSnackbarError(
              context, "Failed to pause playback", 5);
        }
      }

     playBack.insideEvent = false;
    }
  

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
