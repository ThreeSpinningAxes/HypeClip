import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/Pages/SongPlayer/Song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

class SongPlayback extends StatefulWidget {
  final Song song;
  
  
  const SongPlayback({ super.key, required this.song });

  @override
  _SongPlaybackState createState() => _SongPlaybackState();
}

class _SongPlaybackState extends State<SongPlayback> {
  final player = AudioPlayer();
  //Future<Color?> imageColor;

  bool paused = false;

    

  @override
  void initState() {
    SpotifyService().playTrack(widget.song.trackId);
    super.initState();
   //imageColor =  await getImagePalette(NetworkImage(widget.artworkUrl));
  }

   @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
    
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
                context.pop();
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                 
                  SizedBox(height: 20,),
                  Image.network(widget.song.songImage ?? widget.song.artistImage!, height: 300),
                  SizedBox(height: 20,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.song.songName!, style: TextStyle(fontSize: 24, color: Colors.white)),
                          SizedBox(height: 4),
                          Text(widget.song.artistName!, style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
                      IconButton(icon: Icon(paused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 36), 
                      onPressed: () async {
                        if (paused) {
                           await SpotifyService().playTrack(widget.song.trackId);
                          setState(() {
                            paused = false;
                          });
                        } else {
                          await SpotifyService().pausePlayback();
                          setState(() {
                            paused = true;
                          });
                        }
                       
                        // var x = await SpotifyService().getAvailableDevices();
                        // print(x);
                      }),
                      IconButton(icon: Icon(Icons.skip_next, color: Colors.white), onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      );
  }
}