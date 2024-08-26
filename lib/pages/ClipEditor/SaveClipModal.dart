import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';
import 'package:hypeclip/Services/UserProfileService.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/StringUtils.dart';

class SaveClipModal extends ConsumerStatefulWidget {
  final Song song;
  final List<double> clipPoints;
  final MusicLibraryService musicLibraryService;

  const SaveClipModal({Key? key, required this.song, required this.clipPoints, required this.musicLibraryService})
      : super(key: key);

  @override
  _SaveClipModalState createState() => _SaveClipModalState();
}

class _SaveClipModalState extends ConsumerState<SaveClipModal> {
  final _formKey = GlobalKey<FormState>();
  String? clipName = '';
  String? clipDescription = '';
  String defaultClipName = '';
  String? playlistName;

  TextEditingController clipNameController = TextEditingController();
  TextEditingController clipDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    defaultClipName =
        "${widget.song.songName} (${Stringutils.getTimeformat(widget.clipPoints[0].toInt())} - ${Stringutils.getTimeformat(widget.clipPoints[1].toInt())})";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.4,
      child: AlertDialog(
        title: Stack(
        children: [
          
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Save Clip',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
        scrollable: true,
        
        insetPadding: EdgeInsets.all(20),
        content: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Form(
            key: _formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  buildSongCard(),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Clip name (optional)",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    autocorrect: false,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      hintText: 'Enter your own name for your clip (optional)',
                      hintStyle: TextStyle(color: Colors.grey,  fontSize: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.6),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    controller: clipNameController,
                    onSaved: (val) {
                      String? value = val?.trim();
                      if (value != null || value != '') {
                        clipName = value;
                      } else {
                        clipName = defaultClipName;
                      }
                      
                    },
                    validator: (clipName) {
                      if (clipName!.length > 32) {
                        return 'Clip name must be less than or equal to 32 characters.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Clip Description (optional)",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    autocorrect: false,
                    controller: clipDescriptionController,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      hintText: 'Enter clip description',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.6),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onSaved: (value) {
                      clipDescription = value;
                    },
                    validator: (clipDescription) {
                      if (clipDescription != null && clipDescription.length > 120) {
                        return 'Clip description must be less than or equal to 120 characters.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          TrackClip clip = TrackClip(
                            song: widget.song,
                            clipName: clipNameController.text == '' ? defaultClipName : clipNameController.text,
                            clipDescription: clipDescriptionController.text,
                            clipPoints: widget.clipPoints,
                            dateCreated: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day), 
                            musicLibraryService: widget.musicLibraryService,
                          );
                          await ref.read(trackClipProvider.notifier).addClipToPlaylist(trackClip: clip);     
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            showSuccessDialog(context);
                          }            
                             // Handle form submission
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        'Save to library',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
         
        ]),
      ),
    );
  }

  void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      BuildContext dialogContext = context;
      
      // Close the dialog after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        } 
      });

      return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      child: AlertDialog(
        insetPadding: EdgeInsets.all(20),
        content: Builder(
      builder: (context) {
        // Get available height and width of the build area of this widget. Make a choice depending on the size.                              
        var height = MediaQuery.of(context).size.height * 0.2;
        var width = MediaQuery.of(context).size.width * 0.4;

        return Container(
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
              SizedBox(height: 20),
              Center(
                child: Text('Successfully Saved Clip!', style: TextStyle(color: Colors.green, fontSize: 20), softWrap: true, textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
              ),
            ],
          ),
        );
      },
    ),
        actions: [
          Center(
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                )),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.white, fontSize: 14),),
            ),
          ),
        ],
      ));
    },
  );
}

  Widget buildSongCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            // Album Image
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Image.network(
                widget.song.songImage ?? widget.song.albumImage!,
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
                  Text(
                    defaultClipName,
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
                    widget.song.artistName!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Song Name and Artist

            // Play/Pause Button
          ],
        ),
      ],
    );
  }
}
