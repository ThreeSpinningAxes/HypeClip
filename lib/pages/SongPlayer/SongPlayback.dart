import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

class SongPlayback extends StatefulWidget {
  final String title;
  final String artist;
  final String artworkUrl;
  
  
  const SongPlayback({ Key? key, required this.title, required this.artist, required this.artworkUrl }) : super(key: key);

  @override
  _SongPlaybackState createState() => _SongPlaybackState();
}

class _SongPlaybackState extends State<SongPlayback> {
  final player = AudioPlayer();
  //Future<Color?> imageColor;

    Future<Color?> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color;
  }

  @override
  void initState() async {
    
    super.initState();
   //imageColor =  await getImagePalette(NetworkImage(widget.artworkUrl));
      
    

  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Image.network(widget.artworkUrl, height: 300),
            SizedBox(height: 20,),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: TextStyle(fontSize: 24, color: Colors.white)),
                    SizedBox(height: 4),
                    Text(widget.artist, style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
                IconButton(icon: Icon(Icons.play_arrow, color: Colors.white, size: 36), onPressed: () {}),
                IconButton(icon: Icon(Icons.skip_next, color: Colors.white), onPressed: () {}),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}