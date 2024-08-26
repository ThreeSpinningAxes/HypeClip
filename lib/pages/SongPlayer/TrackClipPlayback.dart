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
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';
import 'package:palette_generator/palette_generator.dart';

class SongPlayback extends ConsumerStatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;

  const SongPlayback({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncInit();
    });

    super.initState();
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
          print(r.statusCode);
          errorPage = GenericErrorPage(
            errorHeader: "Error with ${widget.service.name.toCapitalized()}",
            errorDescription: jsonDecode(r.body)['error']['message'],
            buttonText: "Retry",
            buttonAction: _refresh,
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
      if (playbackState.currentProgress == null ||
          playbackState.currentProgress!.inMilliseconds ==
              Duration.zero.inMilliseconds) {
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
              );
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
    final Song currentSong =
        ref.watch(playbackProvider).playbackState.currentSong!;
    final PlaybackState playbackState =
        ref.watch(playbackProvider).playbackState;
    final bool fromListOfTracks =
        playbackState.songs != null && playbackState.songs!.length > 1;

    return Container(
      decoration: BoxDecoration(
        gradient: playbackState.domColorLinGradient,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            heightFactor: 1,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              onPressed: () {
                context.pop();
                if (!error) {
                  ref.read(miniPlayerVisibilityProvider.notifier).state = true;
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
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
                          Text(currentSong.songName ?? 'Unknown Song Name',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(currentSong.artistName!,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (fromListOfTracks)
                        IconButton(
                            icon:
                                Icon(Icons.skip_previous, color: Colors.white),
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
                            if (!insideEvenHandler) {
                              setState(() {
                                insideEvenHandler = true;
                              });

                              if (playbackState.paused!) {
                                if (playbackState
                                        .currentProgress!.inMilliseconds >=
                                    currentSong.duration!.inMilliseconds) {
                                  await _seek(seek: 0);
                                } else {
                                  await _playSong(
                                      position: playBack
                                          .currentProgress.inMilliseconds);
                                }
                              } else {
                                bool? r = await playBack.pauseTrack();
                                if (r == false) {
                                  ShowSnackBar.showSnackbarError(
                                      context, "Failed to pause playback", 5);
                                }
                              }
                              setState(() {
                                insideEvenHandler = false;
                              });
                            }

                            // var x = await SpotifyService().getAvailableDevices();
                            // print(x);
                          }),
                      if (fromListOfTracks)
                        IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
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
                      onPressed: () {
                        context.pushNamed('clipEditor');
                      },
                      icon: Icon(
                        Icons.cut,
                        color: Colors.white,
                      )),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ProgressBar(
                      // baseBarColor: Colors.black,
                      progressBarColor: Colors.white,
                      baseBarColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      progress: playBack.playbackState.currentProgress!,
                      //buffered: Duration(milliseconds: 2000),
                      total: currentSong.duration!,

                      onSeek: (duration) async {
                        if (insideEvenHandler) {
                          return;
                        }
                        setState(() {
                          insideEvenHandler = true;
                        });
                        if (playbackState.paused!) {
                          setState(() {
                            playBack.playbackState.currentProgress = duration;
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
    );
  }

  Future<void> _playNextSong() async {
    Response r = await ref.read(playbackProvider).playNextTrack();
    if (r.statusCode != 200 && r.statusCode != 204) {
      if (mounted) {
        setState(() {
          ShowSnackBar.showSnackbarError(
              context, jsonDecode(r.body)['error']['message'], 5);
          error = true;
        });
      }
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
      if (mounted) {
        setState(() {
          ShowSnackBar.showSnackbarError(
              context, jsonDecode(r.body)['error']['message'], 5);
          error = true;
        });
      }
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
}
