import 'package:flutter/material.dart';

class Trackui {
  static Widget buildTrackCard(BuildContext context, {required String trackName,
      required String artistName, String? albumImageURL}) {
    return Card(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              // Album Image
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: albumImageURL != null ? Image.network(
                  albumImageURL,
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ) : Container(
                  width: 40.0,
                  height: 40.0,
                  color: Colors.grey,
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                      artistName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ),
      
              // Song Name and Artist
      
              // Play/Pause Button
            ],
          ),
        ],
      ),
    );
  }
}
