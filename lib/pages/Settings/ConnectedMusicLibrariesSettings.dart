import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Entities/UserConnectedMusicServiceDB.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Pages/Settings/GenericSettingsPage.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Widgets/ConfirmationDialog.dart';
import 'package:hypeclip/main.dart';

class ConnectedMusicLibrariesSettings extends ConsumerStatefulWidget {
  const ConnectedMusicLibrariesSettings({super.key});

  @override
  _ConnectedMusicLibrariesSettingsState createState() =>
      _ConnectedMusicLibrariesSettingsState();
}

class _ConnectedMusicLibrariesSettingsState
    extends ConsumerState<ConnectedMusicLibrariesSettings> {
  bool _isLoading = false;
  List<MusicLibraryService> unconnectedServices =
      MusicLibraryService.values.toList().where((s) => s != MusicLibraryService.unknown).toList();
  List<MusicLibraryService> connectedServices = [];

  @override
  void initState() {
    super.initState();

    for (UserConnectedMusicService service
        in db.getFirstUser()!.connectedMusicStreamingServices) {
      MusicLibraryService s =
          getMusicLibraryServiceName(service.musicLibraryServiceDB);
      unconnectedServices.remove(s);
      connectedServices.add(s);
    }
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: connectedServices.length,
              itemBuilder: (context, index) {
                MusicLibraryService service = connectedServices[index];
                return MusicLibraryServiceTile(
                  service: service,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                                centerText: true,
                                title: 'Disconnect Account',
                                content:
                                    'Are you sure you want to disconnect this account? (Data will be lost)',
                                primaryConfirmText: 'Disconnect',
                                secondConfirmText: 'Disconnect, but keep data',
                                
                                cancelText: 'Cancel',
                              
                                secondConfirmButtonColor: Colors.lightBlue,

                                onPrimaryConfirm: () {
                                  db.disconnectMusicService(
                                      service: service, deleteData: true);
                                  // db.dbCleanup(service: service);
                                  unconnectedServices.add(service);
                                  connectedServices.remove(service);
                                  context.pop();

                                 
                                    ShowSnackBar.showSnackbar(
                                      context,
                                      message: "Disconnected ${service.name}",
                                      seconds: 3,
                                    );
                                  
                                },
                                
                                onSecondConfirm: () {
                                  db.disconnectMusicService(
                                      service: service, deleteData: false);
                                  unconnectedServices.add(service);
                                  connectedServices.remove(service);
                                  context.pop();
                                    ShowSnackBar.showSnackbar(
                                      context,
                                      message: "Disconnected ${service.name} and cached data",
                                      seconds: 3,
                                    );
                                  
                                },
                                onCancel: () => Navigator.of(context).pop(),
                              )).then((val) {
                        setState(() {});
                      }); //refresh the lists
                    },
                  ),
                );
              },
            ),
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
          Expanded(
            child: ListView.builder(
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

                        Map<String, dynamic>? data = await MusicServiceHandler(
                                service: unconnectedServices[index])
                            .authenticate(unconnectedServices[index]);
                        if (data != null) {
                          connectedServices.add(unconnectedServices[index]);
                          unconnectedServices
                              .remove(unconnectedServices[index]);
                          
                            if (context.mounted) {
                              ShowSnackBar.showSnackbar(
                              context,
                              message:
                                  "Connected ${unconnectedServices[index].name}",
                              seconds: 3,
                            );
                            }
                          
                        } else {
                          
                            if (context.mounted) {
                              ShowSnackBar.showSnackbar(
                                context,
                                message: "Failed to connect ${unconnectedServices[index].name}",
                                seconds: 3,
                                textStyle: TextStyle(color: Colors.red),
                              );
                            }
                          
                        }
                        // if (data != null) {
                        //   await ref
                        //       .read(musicServicesProvider.notifier)
                        //       .addMusicService(unconnectedServices[index], data);
                        // }
                        setState(() {
                          _isLoading = false;
                        });
                      },
                    ),
                  );
                }),
          ),
          SizedBox(height: 70),
        ],
      ),
    );
  }
}
