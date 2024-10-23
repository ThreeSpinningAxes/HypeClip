import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Pages/Explore/noConnectedAccounts.dart';
import 'package:hypeclip/Pages/Explore/ConnectedAccounts.dart';
import 'package:hypeclip/main.dart';

class Explore extends ConsumerWidget {
  Explore({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final Stream connectedServicesStream = db.userConnectedMusicServiceBox.query().watch(triggerImmediately: true).map((services) => services.find());
    Widget page;
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: StreamBuilder(stream: connectedServicesStream, 
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data.length > 0) {
                page = ConnectedAccounts();
            }
            else {
               WidgetsBinding.instance.addPostFrameCallback((_) {
                print(GoRouterState.of(context).uri.toString());
                if (GoRouterState.of(context).uri.toString().contains('/explore')) {
                  context.go('/explore');
                }
              });
              page = NoConnectedAccounts();
            }
            return SafeArea(child:
             page);
          }
          ),
        ),
      );
    
  }
}