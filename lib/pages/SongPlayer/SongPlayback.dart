import 'dart:async';
import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';
import 'package:palette_generator/palette_generator.dart';

class SongPlayback extends ConsumerStatefulWidget {
  final List songs;
  final int songIndex;

  final MusicLibraryService service = MusicLibraryService.spotify;

  const SongPlayback(
      {
        super.key,
        required this.songs,
        required this.songIndex
      });

  @override
  _SongPlaybackState createState() => _SongPlaybackState();
}

class _SongPlaybackState extends ConsumerState<SongPlayback> {
  Timer? progressTimer;
  Duration currentProgress = Duration.zero;
  bool _isLoading = false;
  int index = 0;
  late final MusicServiceHandler musicServiceHandler;
  late Song currentSong;
  LinearGradient? domColorLinGradient;
  bool isSeeking = false;

  //Future<Color?> imageColor;

  bool paused = true;
  @override
  void initState() {
    musicServiceHandler = MusicServiceHandler(service: widget.service);
    index = widget.songIndex;
    currentSong = widget.songs[index];
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncInit();
    });
    _isLoading = false;

    super.initState();
    //imageColor =  await getImagePalette(NetworkImage(widget.artworkUrl));
  }

  _asyncInit() async {
    SpotifyService().isSpotifyAppOpen().then((isOpen) async {
      if (!isOpen) {
        ShowSnackBar.showSnackbarError(
            context,
            "Make sure the ${widget.service.name.toCapitalized()} app is running on your device and is active",
            5);
      } else {
        domColorLinGradient = await getImagePalette(currentSong.albumImage);
        await _playSong(currentSong, 0);
      }
    });
  }

  @override
  void dispose() {
    progressTimer?.cancel();
    super.dispose();
  }

  void startProgressTimer() {
    progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (currentProgress < currentSong.duration!) {
        if (mounted) {
          setState(() {
            currentProgress =
                Duration(milliseconds: currentProgress.inMilliseconds + 100);
          });
        }
      } else {
        timer.cancel();
        await musicServiceHandler.pausePlayback(); // Stop the timer if the song ends
      }
    });
  }

  void resetProgressTimer() {
    progressTimer?.cancel();
    setState(() {
      currentProgress = Duration.zero;
    });
  }

  void pausePlayback() {
    // Implement pause functionality
    if (mounted) {
      setState(() {
        paused = true;
        progressTimer?.cancel();
      });
      // Stop the progress timer
    }
  }

  void resumePlayback() {
    // Implement resume functionality
    if (mounted) {
      setState(() {
        paused = false;
        startProgressTimer();
      });
    }

    // Resume the progress timer
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
    return Container(
      decoration: BoxDecoration(
        gradient: domColorLinGradient,
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
                setState(() {
                  progressTimer?.cancel();
                });
      
                context.pop();
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Image.network(currentSong.songImage ?? currentSong.albumImage!,
                      height: 300),
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
                          Text(currentSong.songName!,
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white)),
                          SizedBox(height: 4),
                          Text(currentSong.artistName!,
                              style: TextStyle(fontSize: 18, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.skip_previous, color: Colors.white),
                          onPressed: () async {
                             if (!isSeeking) {
                            await _playPreviousSong();
                             }
                          }),
                      IconButton(
                          icon: Icon(paused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white, size: 36),
                          onPressed: () async {
                            if (!isSeeking) {
                              
                            
                            if (paused) {
                              await _playSong(
                                  currentSong, currentProgress.inMilliseconds);
                            } else {
                              await musicServiceHandler.pausePlayback();
                              pausePlayback();
                            }
                            }
      
                            // var x = await SpotifyService().getAvailableDevices();
                            // print(x);
                          }),
                      IconButton(
                          icon: Icon(Icons.skip_next, color: Colors.white),
                          onPressed: () async {
                             if (!isSeeking) {
                            await _playNextSong();
                             }
                          }),
                    ],
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ProgressBar(
                      // baseBarColor: Colors.black,
                      progressBarColor: Colors.white,
                      baseBarColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      progress: currentProgress,
                      //buffered: Duration(milliseconds: 2000),
                      total: currentSong.duration!,
      
                      onSeek: (duration) async {
                        setState(() {
                          isSeeking = true;
                        });
                        await _playSong(
                            currentSong, duration.inMilliseconds);
                        setState(() {
                          paused = false;
                          currentProgress = duration;
                          isSeeking = false;
                        });
      
                        //resumePlayback();
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
    int nextIndex = index + 1;
    if (nextIndex >= widget.songs.length) {
      nextIndex = 0;
    }
    index = nextIndex;
    currentSong = widget.songs[index];

          domColorLinGradient = await getImagePalette(currentSong.albumImage);

    setState(() {
      resetProgressTimer();
    });
    await musicServiceHandler.playTrack(currentSong.trackURI, position: 0);
    if (mounted) {
      setState(() {
        paused = false;
        startProgressTimer();
      });
    }
  }

  Future<void> _playPreviousSong() async {
    int previousIndex = index - 1;
    if (previousIndex < 0) {
      previousIndex = widget.songs.length - 1;
    }
    index = previousIndex;
    currentSong = widget.songs[index];
    domColorLinGradient = await getImagePalette(currentSong.albumImage);
    setState(() {
      resetProgressTimer();
    });
    await musicServiceHandler.playTrack(currentSong.trackURI, position: 0);
    if (mounted) {
      setState(() {
        paused = false;  
        startProgressTimer();
      });
    }
  }

  Future<void> _playSong(Song song, int position) async {
    Response? r =
        await musicServiceHandler.playTrack(song.trackURI, position: position);
    Response response = r!;
    if (response.statusCode == 204 || response.statusCode == 200) {
      if (mounted) {
        setState(() {
          paused = false;
        });
      }
      if (progressTimer == null || !progressTimer!.isActive) {
        resumePlayback();
      }
    } else {
      if (mounted) {
        setState(() {
          paused = true;
        });
      }
      ShowSnackBar.showSnackbarError(
          context, jsonDecode(response.body)['error']['message'], 5);
      pausePlayback();
    }
  }

    Future<LinearGradient?> getImagePalette(String? imageURL) async {
      if (imageURL == null) {
        return null;
      }
    final ImageProvider imageProvider = NetworkImage(imageURL);
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
        Color? domColor = paletteGenerator.dominantColor?.color;
    LinearGradient linearGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
  Theme.of(context).scaffoldBackgroundColor,
  domColor?.withOpacity(0.33) ?? Colors.black.withOpacity(0.1),
  domColor?.withOpacity(0.66) ?? Colors.black.withOpacity(0.3),
  domColor ?? Colors.black,
  domColor?.withOpacity(0.66) ?? Colors.black.withOpacity(0.7),
  domColor?.withOpacity(0.33) ?? Colors.black.withOpacity(0.3),
  Theme.of(context).scaffoldBackgroundColor,
],
stops: [
      0.0,
      0.175,
      0.3125,
      0.5,
      0.6875,
      0.825,
      1.0,
    ],
    );
    return linearGradient;
  }
}
