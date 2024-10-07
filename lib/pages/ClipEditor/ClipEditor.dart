import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_multi_slider/flutter_multi_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/ErrorPages/GenericErrorPage.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Pages/ClipEditor/SaveClipModal.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';

class ClipEditor extends ConsumerStatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;
  final bool? showMiniPlayerOnExit;
  final bool fromSongPlaybackWidget;

  const ClipEditor(
      {super.key,
      this.showMiniPlayerOnExit,
      this.fromSongPlaybackWidget = true});

  @override
  _ClipEditorState createState() => _ClipEditorState();
}

class _ClipEditorState extends ConsumerState<ClipEditor> {
  bool _isLoading = true;
  bool insidePlaybackSlider = false;
  bool insideClipSlider = false;
  bool inEvent = false;
  Widget errorPage = GenericErrorPage();
  late MusicServiceHandler musicServiceHandler;

  //List<double> clipValues = [0, 0];
  List<double> trackProgress = [0];

  bool initError = false;
  bool error = false;

  @override
  void initState() {
    super.initState();
    if (ref.exists(playbackProvider)) {
      
      musicServiceHandler = ref.read(playbackProvider).musicServiceHandler;
    }

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
          );
          _isLoading = false;
          error = true;
          initError = true;
        });
      }
    } else {
      PlaybackNotifier playbackNotifier = ref.read(playbackProvider.notifier);
      PlaybackState playbackState = ref.read(playbackProvider).playbackState;
      if (playbackState.domColorLinGradient == null) {
        ref.read(playbackProvider).setImagePalette();
      }
      if (playbackState.currentProgress == Duration.zero) {
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
              return;
            });
          }
        }
      }

      setState(() {
        error = false;
        initError = false;
      });

      double startPos =
          playbackState.currentProgress!.inMilliseconds.toDouble();
      double trackLength =
          playbackState.currentSong!.duration!.inMilliseconds.toDouble();

      playbackNotifier.updatePlaybackState(clipValues: [0.0, trackLength], inClipEditorMode: true);
      trackProgress = [startPos];
      //clipValues = playbackState.clipValues!;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
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

    if (initError || error) {
      return errorPage;
    }
    final playBack = ref.watch(playbackProvider);
    final Song currentSong =
        ref.watch(playbackProvider).playbackState.currentSong!;
    final PlaybackState playbackState =
        ref.watch(playbackProvider).playbackState;

    final String trackName = currentSong.songName ?? 'Unknown Song Name';
    final String artistName = currentSong.artistName ?? 'Unknown Artist Name';
    final String trackImage = currentSong.albumImage ?? currentSong.songImage!;
    List<double> clipValues = playbackState.clipValues!;

    if (!insidePlaybackSlider) {
      if (trackProgress[0] >= playbackState.clipValues![1]) {
        // if (!playbackState.paused!) {
        //   setState(() {
        //     playbackState.paused = true;
        //   });

        //   playBack.pauseTrack();
        // }
        // setState(() {
        //   playbackState.currentProgress =
        //       Duration(milliseconds: clipValues[1].toInt());
        //   trackProgress[0] = clipValues[1];
        // });
      } else {
        // setState(() {
        //   if (!insideClipSlider &&
        //       playbackState.currentProgress!.inMilliseconds >= clipValues[1]) {
        //     //trackProgress[0] = clipValues[1];
        //   } else {
        //     trackProgress[0] =
        //         playbackState.currentProgress!.inMilliseconds.toDouble();
        //   }
        // });
      }
      setState(() {
        trackProgress[0] =
            playbackState.currentProgress!.inMilliseconds.toDouble();
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: playbackState.domColorLinGradient,
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
                      onPressed: () async {
                        if (inEvent) {
                          return;
                        }
                        if (!widget.fromSongPlaybackWidget) {
                          await ref.read(playbackProvider).pauseTrack();
                        }
                        if (context.mounted) {
                          ref
                              .read(playbackProvider)
                              .updatePlaybackState(inClipEditorMode: false);
                          context.pop();
                        }

                        if (widget.showMiniPlayerOnExit == true) {
                          ref
                              .read(miniPlayerVisibilityProvider.notifier)
                              .state = true;
                        }
                      }),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        trackImage,
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
                                artistName,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(
                                  playbackState.paused!
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: Colors.white,
                                  size: 36),
                              onPressed: () async {
                                if (!inEvent) {
                                  setState(() {
                                    inEvent = true;
                                  });
                                  if (playbackState.paused! &&
                                      trackProgress[0] >=
                                          clipValues[1].toInt()) {
                                    setState(() {
                                      playbackState.currentProgress = Duration(
                                          milliseconds: clipValues[0].toInt());
                                    });

                                    await _seek(seek: clipValues[0].toInt());
                                    setState(() {
                                      trackProgress[0] = playbackState
                                          .currentProgress!.inMilliseconds
                                          .toDouble();
                                    });
                                  } else if (playbackState.paused!) {
                                    await _playSong(
                                        position: playbackState
                                            .currentProgress!.inMilliseconds);
                                  } else {
                                    bool? r = await playBack.pauseTrack();
                                    if (r == false) {
                                      ShowSnackBar.showSnackbarError(context,
                                          "Failed to pause playback", 5);
                                    }
                                  }
                                  setState(() {
                                    inEvent = false;
                                  });
                                }

                                // var x = await SpotifyService().getAvailableDevices();
                                // print(x);
                              }),
                          IconButton(
                              icon: Icon(Icons.refresh,
                                  color: Colors.white, size: 36),
                              onPressed: () async {
                                if (!inEvent) {
                                  setState(() {
                                    inEvent = true;
                                  });

                                  await _seek(seek: clipValues[0].toInt());

                                  setState(() {
                                    trackProgress[0] = ref
                                        .read(playbackProvider)
                                        .playbackState
                                        .currentProgress!
                                        .inMilliseconds
                                        .toDouble();
                                    inEvent = false;
                                  });
                                }

                                // var x = await SpotifyService().getAvailableDevices();
                                // print(x);
                              }),
                          IconButton(
                            icon:
                                Icon(Icons.save, color: Colors.green, size: 36),
                            onPressed: () {
                              _showSaveClipModal();
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 20),

                      // PROGRESS BAR
                      MultiSlider(
                          values: trackProgress,
                          rangeColors: [
                            Colors.white,
                            Colors.white.withOpacity(0.4)
                          ],
                          trackbarBuilder: (value) => TrackbarOptions(
                              color: Colors.black, isActive: true, size: 5.0),
                          min: 0.0,
                          max: currentSong.duration!.inMilliseconds.toDouble(),
                          thumbBuilder: (value) => ThumbOptions(
                                color: Colors.white,
                                radius: 8.0,
                              ),
                          selectedIndicator: (value) => IndicatorOptions(
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                                // Customize the selected indicator options based on the value
                                formatter: (v) => getTimeformat(v.toInt()),
                                // Add other properties as needed
                              ),
                          indicator: (value) {
                            return IndicatorOptions(
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              // Customize the indicator options based on the value
                              formatter: (v) => getTimeformat(v.toInt()),

                              // Add other properties as needed
                            );
                          },
                          onChanged: (updatedTrackProgress) async {
                            if (!insideClipSlider) {
                              if (updatedTrackProgress[0] >= clipValues[1]) {
                                updatedTrackProgress[0] = clipValues[1];
                              } else if (updatedTrackProgress[0] <=
                                  clipValues[0]) {
                                updatedTrackProgress[0] = clipValues[0];
                              }
                              setState(() {
                                trackProgress = updatedTrackProgress;
                              });
                            }
                          },
                          onChangeStart: (value) {
                            if (!insideClipSlider) {
                              setState(() {
                                insidePlaybackSlider = true;
                                inEvent = true;
                              });
                            }
                          },
                          onChangeEnd: (updatedTrackProgress) async {
                            if (!insideClipSlider) {
                              // if you seek past the end of the clip, set the progress to the end of the clip and pause the song
                              if (updatedTrackProgress[0] >= clipValues[1]) {
                                if (!playbackState.paused!) {
                                  setState(() {
                                    playbackState.paused = true;
                                  });
                                  await playBack.pauseTrack();
                                }

                                setState(() {
                                  playbackState.currentProgress = Duration(
                                      milliseconds:
                                          updatedTrackProgress[0].toInt());
                                });
                              }
                              // if you seek before the start of the clip, set the progress to the start of the clip
                              // else if (updatedTrackProgress[0] < clipValues[0]) {
                              //   await _seek(
                              //       seek: Duration(seconds: updatedTrackProgress[0].toInt())
                              //           .inMilliseconds);
                              else {
                                setState(() {
                                  playbackState.currentProgress = Duration(
                                      milliseconds:
                                          updatedTrackProgress[0].toInt());
                                });
                                if (!playbackState.paused!) {
                                  await _seek(
                                      seek: updatedTrackProgress[0].toInt());
                                }
                              }
                            }
                            setState(() {
                              insidePlaybackSlider = false;
                              inEvent = false;
                            });
                          }),
                      SizedBox(
                        height: 20,
                      ),

                      //CLIP SLIDER
                      MultiSlider(
                        values: clipValues,
                        height: 25,
                        rangeColors: [
                          Colors.black,
                          Color.fromARGB(255, 8, 104, 187),
                          Colors.black
                        ],
                        trackbarBuilder: (value) => TrackbarOptions(
                            color: Colors.black, isActive: true, size: 5.0),
                        min: 0.0,
                        max: currentSong.duration!.inMilliseconds.toDouble(),
                        thumbBuilder: (value) {
                          if (value.index == 0) {
                            return ThumbOptions(
                              color: Colors.white,
                              radius: 8.0,
                            );
                          } else {
                            return ThumbOptions(
                              color: Colors.white,
                              radius: 8.0,
                            );
                          }
                        },
                        selectedIndicator: (value) {
                          return IndicatorOptions(
                            style: TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                            // Customize the selected indicator options based on the value
                            formatter: (v) => getTimeformat(v.toInt()),
                            // Add other properties as needed
                          );
                        },
                        indicator: (value) {
                          return IndicatorOptions(
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            // Customize the indicator options based on the value
                            formatter: (v) => getTimeformat(v.toInt()),

                            // Add other properties as needed
                          );
                        },
                        onChanged: (updatedClipValues) async {
                          if (!insidePlaybackSlider) {
                            setState(() {
                              clipValues = updatedClipValues;
                            });
                            playBack.updatePlaybackState(
                                clipValues: clipValues);
                          }
                        },
                        onChangeStart: (value) {
                          if (!inEvent && !insidePlaybackSlider) {
                            setState(() {
                              insideClipSlider = true;
                              inEvent = true;
                            });
                            playBack.insideEvent = true;
                          }
                        },
                        onChangeEnd: (value) async {
                          if (!insidePlaybackSlider) {
                            if (clipValues[0] > trackProgress[0]) {
                              if (!playbackState.paused!) {
                                await _seek(
                                    seek: Duration(
                                            milliseconds: clipValues[0].toInt())
                                        .inMilliseconds);
                                setState(() {
                                  trackProgress[0] = clipValues[0];
                                });
                              } else {
                                playBack.updatePlaybackState(
                                    currentProgress: Duration(
                                        milliseconds: clipValues[0].toInt()));
                                setState(() {
                                  trackProgress[0] = clipValues[0];
                                });
                              }
                            } else if (clipValues[1] < trackProgress[0]) {
                              if (playbackState.paused!) {
                                setState(() {
                                  trackProgress[0] = clipValues[1];
                                });
                                playBack.updatePlaybackState(
                                    clipValues: clipValues,
                                    currentProgress: Duration(
                                        milliseconds: clipValues[1].toInt()));
                              } else {
                                int oldPos = playbackState
                                    .currentProgress!.inMilliseconds;
                                setState(() {
                                  trackProgress[0] = clipValues[1];
                                });
                                playBack.updatePlaybackState(
                                    paused: true,
                                    currentProgress: Duration(
                                        milliseconds: clipValues[1].toInt()));

                                bool? success = await playBack.pauseTrack();
                                playBack.updatePlaybackState(
                                    currentProgress: Duration(
                                        milliseconds: clipValues[1].toInt()));
                                if (success == false) {
                                  setState(() {
                                    trackProgress[0] = oldPos.toDouble();
                                  });
                                }else {
                                  setState(() {
                                    trackProgress[0] = clipValues[1];
                                  });
                                }
                              }
                            }
                            setState(() {
                            inEvent = false;
                            insideClipSlider = false;
                          });
                            playBack.insideEvent = false;
                          }
                          
                          
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 26, right: 26),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTimeformat(clipValues[0].toInt()),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              getTimeformat(clipValues[1].toInt()),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
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

  void _showSaveClipModal() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SaveClipModal(
            song: ref.read(playbackProvider).playbackState.currentSong!,
            clipPoints: [
              ...ref.read(playbackProvider).playbackState.clipValues!
            ],
            musicLibraryService: widget.service,
            fromSongPlayback: widget.fromSongPlaybackWidget,
          );
        });
  }

  String getTimeformat(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final hours = duration.inHours;
    final remainingSeconds = duration.inSeconds % 60;
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
        });
      }
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
