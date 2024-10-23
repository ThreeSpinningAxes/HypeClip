import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Pages/Explore/noConnectedAccounts.dart';
import 'package:hypeclip/Services/UserProfileService.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';
import 'dart:developer' as debug;

import 'package:hypeclip/main.dart';

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
    connectedServices = UserProfileService.getConnectedMusicLibraries();
  }

  @override
  Widget build(BuildContext context) {
   final Stream connectedServicesStream = db.userConnectedMusicServiceBox.query().watch(triggerImmediately: true).map((services) => services.find());

    return StreamBuilder(
      stream: connectedServicesStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.length > 0) {
          return ListView(
        children: [
          Text('Connected Music Libraries',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(
              height:
                  16), // Adds a little space between the header and descriptor text
          // Text(
          //   'Explore your connected music accounts to start clipping!',
          //   style: Theme.of(context).textTheme.bodyMedium, // This assumes bodySmall is smaller than headlineSmall
          // ),
          SizedBox(height: 20), // Adds space before the list starts
          ListView.builder(
            shrinkWrap:
                true, // Needed to nest ListView.builder inside another ListView
            physics: ScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              MusicLibraryService service = getMusicLibraryServiceName(snapshot.data[index].musicLibraryServiceDB);
              return _buildServiceRow(service);
            },
          ),
        ],
      );
        } else {
          return NoConnectedAccounts();
        }
      },
     
    );
  }

  Widget _buildServiceRow(MusicLibraryService service) {

    return ListTile(
        leading: getSVGIcon(service),
        title: Text(
          service.name.toCapitalized(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
         
            debug.log('Connected to${service.name}');
            context.pushNamed('explore/connectedAccounts/browseMusicPlatform');
          
        });
  }
}
