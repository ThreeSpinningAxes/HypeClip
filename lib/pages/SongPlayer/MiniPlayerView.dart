import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/ErrorPages/GenericErrorPage.dart';
import 'package:hypeclip/Pages/SongPlayer/SongPlayback.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Providers/PlaybackState.dart';
import 'package:text_marquee/text_marquee.dart';

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

  @override
  Widget build(BuildContext context) {
    final bool miniPlayerVisibility = ref.watch(miniPlayerVisibilityProvider);
    if (!miniPlayerVisibility) {
      return SizedBox.shrink();
    }
    final playBack = ref.watch(playbackProvider);
    final Song currentSong =
        ref.watch(playbackProvider).playbackState.currentSong!;
    final PlaybackState playbackState =
        ref.watch(playbackProvider).playbackState;

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
            color: playbackState.domColorLinGradient?.colors[3],
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
                            TextMarquee(
                              delay: Duration(seconds: 0),
                              currentSong.songName!,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)
                                  ),
                            
                            SizedBox(height: 4),
                            TextMarquee(currentSong.artistName!,
                                style: TextStyle(fontSize: 12, color: Colors.white,
                                
                                )),
                          ],
                        ),
                      
                    ),
                    
                
                    // Song Name and Artist
                
                    // Play/Pause Button
                    
                    
                    IconButton(
                      icon: Icon(
                        playbackState.paused! ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (!insideEvenHandler) {
                          insideEvenHandler = true;
                          if (playbackState.paused!) {
                            await _playSong(
                                position:
                                    playBack.timer.currentProgress.inMilliseconds);
                          } else {
                            bool? r = await playBack.pauseSong();
                            if (r == false) {
                              //error
                            }
                          }
                          insideEvenHandler = false;
                        }
                
                        // var x = await SpotifyService().getAvailableDevices();
                        // print(x);
                      },
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.cut, color: Colors.white, size: 16,)),
                
                    
                  ],
                ),
                
                ProgressBar(
                      progress: playbackState.currentProgress!,
                      total: currentSong.duration!,
                      onSeek: (duration) {
                        _seek(seek: duration.inMilliseconds);
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
      ),
    );
  }

  Future<void> _playNextSong() async {
    Response r = await ref.read(playbackProvider).playNextTrack();
    if (r.statusCode != 200 && r.statusCode != 204) {
      if (mounted) {
        //error
      }
    } else {
      ref.read(playbackProvider).playbackState.currentSong!.albumImage;
    }
  }

  Future<void> _playPreviousSong() async {
    insideEvenHandler = true;
    Response r = await ref.read(playbackProvider).playPreviousTrack();
    if (r.statusCode != 200 && r.statusCode != 204) {
      if (mounted) {
        setState(() {
          //error
        });
      }
    } else {
      ref.read(playbackProvider).playbackState.currentSong!.albumImage;
    }
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
}
