import 'dart:async';
import 'dart:convert';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';


class SongPlayback extends StatefulWidget {
  final Song song;

  final MusicLibraryService service = MusicLibraryService.spotify;

  const SongPlayback({super.key, required this.song});

  @override
  _SongPlaybackState createState() => _SongPlaybackState();
}

class _SongPlaybackState extends State<SongPlayback> {
  Timer? progressTimer;
  Duration currentProgress = Duration.zero;
  bool _isLoading = false;

  //Future<Color?> imageColor;

  bool paused = true;

  @override
  void initState() {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_){
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
        await SpotifyService().playTrack(widget.song.trackURI, position: 0).then((response) {
          if (response.statusCode == 204 || response.statusCode == 200) {
            resumePlayback();
          } else {
            ShowSnackBar.showSnackbarError(
                context, jsonDecode(response.body)['error']['message'], 5);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    progressTimer?.cancel();
    super.dispose();
  }

    void startProgressTimer() {
    progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (currentProgress < widget.song.duration!) {
        
        setState(() {
          currentProgress = Duration(milliseconds: currentProgress.inMilliseconds + 100);
        });
      } else {
        timer.cancel(); // Stop the timer if the song ends
      }
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
        child: CircularProgressIndicator(color: Colors.white,),
      );
    }
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          heightFactor: 1,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
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
                Image.network(widget.song.songImage ?? widget.song.albumImage!,
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
                        Text(widget.song.songName!,
                            style:
                                TextStyle(fontSize: 24, color: Colors.white)),
                        SizedBox(height: 4),
                        Text(widget.song.artistName!,
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
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
                        onPressed: () {}),
                    IconButton(
                        icon: Icon(paused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white, size: 36),
                        onPressed: () async {
                          if (paused) {
                            Response response = await SpotifyService()
                                .playTrack(widget.song.trackURI, position: currentProgress.inMilliseconds);
                            if (response.statusCode == 204 ||
                                response.statusCode == 200) {
                              resumePlayback();
                            } else {
                              ShowSnackBar.showSnackbarError(
                                  context,
                                  "Make sure the ${widget.service.name.toCapitalized()} app is running on your device! ${response.statusCode}",
                                  5);
                            }
                          } else {
                            
                            await SpotifyService().pausePlayback();
                            pausePlayback();
                          }

                          // var x = await SpotifyService().getAvailableDevices();
                          // print(x);
                        }),
                    IconButton(
                        icon: Icon(Icons.skip_next, color: Colors.white),
                        onPressed: () {}),
                  ],
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: ProgressBar(
                    
                   // baseBarColor: Colors.black,
                    progressBarColor: Colors.white,
                    thumbColor: Colors.white,
                    progress: currentProgress,
                    //buffered: Duration(milliseconds: 2000),
                    total: widget.song.duration!,
                    
                    onSeek: (duration) async {
                      await SpotifyService().playTrack(widget.song.trackURI,
                          position: duration.inMilliseconds);
                      setState(() {
                        currentProgress = duration;               
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
    );
  }
}
