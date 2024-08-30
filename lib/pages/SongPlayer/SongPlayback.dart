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
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';

class SongPlayback extends ConsumerStatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;
  final bool? inTrackClipPlaybackMode;

  const SongPlayback({super.key, this.inTrackClipPlaybackMode});

  @override
  _SongPlaybackState createState() => _SongPlaybackState();
}

class _SongPlaybackState extends ConsumerState<SongPlayback> {
  bool _isLoading = true;
  late final MusicServiceHandler musicServiceHandler;
  bool insideEvenHandler = false;
  bool error = false;
  bool initError = false;
  GenericErrorPage errorPage = GenericErrorPage();

  @override
  void initState() {
    super.initState();
    musicServiceHandler = MusicServiceHandler(service: widget.service);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncInit();
    });
  }

  void _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await _asyncInit();
  }

  _asyncInit() async {
    Response r = await musicServiceHandler.isStreaingServiceAppOpen();
    if (r.statusCode != 200 && r.statusCode != 204) {
      if (mounted) {
        setState(() {
          // ShowSnackBar.showSnackbarError(
          //     context,
          //     "Make sure the ${widget.service.name.toCapitalized()} app is running on your device and is active",
          //     5);
          print(r.statusCode);
          errorPage = GenericErrorPage(
            errorHeader: "Error with ${widget.service.name.toCapitalized()}",
            errorDescription: jsonDecode(r.body)['error']['message'],
            buttonText: "Retry",
            buttonAction: _refresh,
            padding: EdgeInsets.all(20),
          );
          _isLoading = false;
          error = true;
          initError = true;
        });
      }
    } else {
      PlaybackState playbackState = ref.read(playbackProvider).playbackState;
      if (playbackState.domColorLinGradient == null) {
        ref.read(playbackProvider).setImagePalette();
      }
      if ((playbackState.currentProgress == null ||
          playbackState.currentProgress!.inMilliseconds ==
              Duration.zero.inMilliseconds)) {
        Response? r = await ref.watch(playbackProvider).playCurrentTrack(0);
        if (r.statusCode != 200 && r.statusCode != 204) {
          if (mounted) {
            setState(() {
              // ShowSnackBar.showSnackbarError(
              //     context, jsonDecode(r.body)['error']['message'], 5);
              errorPage = GenericErrorPage(
                  errorHeader:
                      "Failed to play track ${playbackState.currentSong!.songName}",
                  errorDescription: jsonDecode(r.body)['error']['message'],
                  buttonText: "Retry",
                  buttonAction: _refresh,
                  padding: EdgeInsets.all(20));
              error = true;
              initError = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              error = false;
              initError = false;
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    if (initError) {
      return errorPage;
    }
    final playBack = ref.watch(playbackProvider);
    final PlaybackState playbackState =
        ref.watch(playbackProvider).playbackState;
    final Song currentSong;
    final String trackName;
    final int trackDuration;

    bool fromListOfTracks;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      currentSong = playbackState.currentTrackClip!.song;
      fromListOfTracks = (playbackState.trackClipQueue != null &&
              playbackState.trackClipQueue!.length > 1) ||
          playbackState.trackClipPlaylist != null;
      trackName = playbackState.currentTrackClip!.clipName;
      trackDuration =
          playbackState.currentTrackClip!.clipLength!.inMilliseconds;
    } else {
      currentSong = playbackState.currentSong!;
      fromListOfTracks =
          playbackState.songs != null && playbackState.songs!.length > 1;
      trackName = currentSong.songName!;
      trackDuration = currentSong.duration!.inMilliseconds;
    }

    if (playbackState.isRepeatMode && !playbackState.paused!) {
      if (playbackState.currentProgress!.inMilliseconds >= trackDuration) {
        setState(() {
          playbackState.currentProgress = Duration.zero;
          playBack.timer.currentProgress = Duration.zero;
          playbackState.paused = false;
          _seek(seek: 0);
        });
      }
    }

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
                      context.pop();
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
                        currentSong.songImage ?? currentSong.albumImage!,
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
                                currentSong.artistName!,
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
                              setState(() {
                                playbackState.isRepeatMode =
                                    !playbackState.isRepeatMode;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (fromListOfTracks)
                                IconButton(
                                    icon: Icon(Icons.skip_previous,
                                        color: Colors.white),
                                    onPressed: () async {
                                      if (!insideEvenHandler) {
                                        setState(() {
                                          insideEvenHandler = true;
                                        });
                                        await _playPreviousSong();
                                        setState(() {
                                          insideEvenHandler = false;
                                        });
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
                                        currentSong, trackDuration);
                                  }),
                              if (fromListOfTracks)
                                IconButton(
                                    icon: Icon(Icons.skip_next,
                                        color: Colors.white),
                                    onPressed: () async {
                                      if (!insideEvenHandler) {
                                        setState(() {
                                          insideEvenHandler = true;
                                        });

                                        await _playNextSong();

                                        setState(() {
                                          insideEvenHandler = false;
                                        });
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
                                if (!insideEvenHandler) {
                                  setState(() {
                                    insideEvenHandler = true;
                                  });
                                  
                                  if (!playbackState.isShuffleMode) {
                                    playBack.shuffleQueue();
                                  } else {
                                    playBack.undueShuffle();
                                  }

                                  setState(() {
                                    insideEvenHandler = false;
                                  });
                                }
                              }),
                        ],
                      ),
                      if (playbackState.inTrackClipPlaybackMode != null &&
                          !playbackState.inTrackClipPlaybackMode!)
                        IconButton(
                            onPressed: () {
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
                            if (insideEvenHandler) {
                              return;
                            }

                            setState(() {
                              insideEvenHandler = true;
                            });

                            if (playbackState.paused!) {
                              setState(() {
                                playBack.playbackState.currentProgress =
                                    duration;
                                playBack.timer.currentProgress = duration;
                              });
                            } else {
                              await _seek(seek: duration.inMilliseconds);
                            }

                            setState(() {
                              insideEvenHandler = false;
                            });
                          },
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
        _isLoading = true;
        error = false;
      });

      ref.read(playbackProvider).setImagePalette();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playPreviousSong() async {
    insideEvenHandler = true;
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
      error = false;
    }
  }

  Future<void> _pausePlayback(Song currentSong, int trackDuration) async {
    if (!insideEvenHandler) {
      setState(() {
        insideEvenHandler = true;
      });
      PlaybackNotifier playBack = ref.read(playbackProvider);
      PlaybackState playbackState = ref.read(playbackProvider).playbackState;
      if (playbackState.paused!) {
        if (playbackState.currentProgress!.inMilliseconds >= trackDuration) {
          await _seek(seek: 0);
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

      setState(() {
        insideEvenHandler = false;
      });
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
