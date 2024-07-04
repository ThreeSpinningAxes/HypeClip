import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Pages/Explore/GenericExplorePage.dart';
import 'package:hypeclip/Services/UserService.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';



class ConnectedAccounts extends StatefulWidget {
  const ConnectedAccounts({super.key});

  @override
  _ConnectedAccountsState createState() => _ConnectedAccountsState();
}

class _ConnectedAccountsState extends State<ConnectedAccounts> {
  late Set<MusicLibraryService> connectedServices;

    @override
  void initState() {
    super.initState();
    connectedServices = Userservice.getConnectedMusicLibraries();
  }

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
    child: ListView(
      children: [
        Text('Connected Music Libraries', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 16), // Adds a little space between the header and descriptor text
        // Text(
        //   'Explore your connected music accounts to start clipping!',
        //   style: Theme.of(context).textTheme.bodyMedium, // This assumes bodySmall is smaller than headlineSmall
        // ),
        SizedBox(height: 20), // Adds space before the list starts
        ListView.builder(
          shrinkWrap: true, // Needed to nest ListView.builder inside another ListView
          physics: ScrollPhysics(),// Disables scrolling for the inner ListView.builder
          itemCount: connectedServices.length,
          itemBuilder: (context, index) {
            MusicLibraryService service = connectedServices.elementAt(index);
            return _buildServiceRow(service);
          },
        ),
      ],
    ),
  );
}

   Widget _buildServiceRow(MusicLibraryService service) {
    Widget icon;
    Function onTap;
    switch (service) {
      case MusicLibraryService.spotify:
        icon = SvgPicture.asset(
                            width: 40,
                            'assets/Spotify_Icon_RGB_Green.svg',
                            semanticsLabel: 'Spotify logo',
                          ); // Replace with Spotify icon
        break;
      // case MusicLibraryService.appleMusic:
      //   icon = Icons.library_music; // Replace with Apple Music icon
      //   break;
      // Add cases for other services
      default:
        icon = Container(); // Fallback icon
    }

    return ListTile(
      leading: icon,
      title: Text(
        service.name.toCapitalized(),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GenericExplorePage(service: service)),
        );
      },
    );
  }
  
}
