import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Pages/Settings/GenericSettingsPage.dart';
import 'package:hypeclip/Providers/musicServicesProvider.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Widgets/ConfirmationDialog.dart';

class ConnectedMusicLibrariesSettings extends ConsumerStatefulWidget {
  const ConnectedMusicLibrariesSettings({super.key});

  @override
  _ConnectedMusicLibrariesSettingsState createState() => _ConnectedMusicLibrariesSettingsState();
}

class _ConnectedMusicLibrariesSettingsState extends ConsumerState<ConnectedMusicLibrariesSettings> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Set<MusicLibraryService> connectedMusicServices = ref.watch(musicServicesProvider);
    List<MusicLibraryService> services = connectedMusicServices.toList();
    List<MusicLibraryService> unconnectedServices = MusicLibraryService.values.where((element) => !connectedMusicServices.contains(element)).toList();
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
    return GenericSettingsPage(
      title: "Your Music Services",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Connected accounts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: connectedMusicServices.length,
            
            itemBuilder: (context, index) {
                return MusicLibraryServiceTile(
                service: services[index],
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(context: context, builder: (context) =>
                  ConfirmationDialog(
                    centerText: true,
                    title: 'Disconnect Account',
                    content: 'Are you sure you want to disconnect this account?',
                    onPrimaryConfirm: () async {
                       await ref.read(musicServicesProvider.notifier).deleteMusicService(services[index]);
                    },
                    onCancel: () => Navigator.of(context).pop(),
                  ));
                  },
                ),
                );
            },
          ),
          SizedBox(height: 20),
          Text(
            'Connect new music service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: unconnectedServices.length,

            itemBuilder: (context, index) {
            return MusicLibraryServiceTile(
              service: unconnectedServices[index],
              trailing: IconButton(
                icon: Icon(Icons.add, color: Colors.green),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                 Map<String, dynamic>? data = await MusicServiceHandler(service: unconnectedServices[index]).authenticate(unconnectedServices[index]);
                 if (data != null) {
                    await ref.read(musicServicesProvider.notifier).addMusicService(unconnectedServices[index], data);
                 }
                 setState(() {
                    _isLoading = false;
                  });
                  if (context.mounted) {
                    ShowSnackBar.showSnackbar(context, message: "Connected ${unconnectedServices[index].name}", seconds: 3,);
                  }
                  
                },
              ),
            );
          }), 
          
        ],
      ),
    );
  }
}