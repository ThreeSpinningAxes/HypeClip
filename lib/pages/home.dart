import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Pages/ConnectMusicServicesPage.dart';
import 'package:hypeclip/Pages/SongPlayer/MiniPlayerView.dart';
import 'package:hypeclip/Providers/musicServicesProvider.dart';

import 'package:hypeclip/Services/UserProfileService.dart';


class Home extends ConsumerStatefulWidget {
  final StatefulNavigationShell child;
  const Home({super.key, required this.child});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  List pageNames = ["Library", "Explore"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.watch(musicServicesProvider.notifier).updateMusicServices();
  }
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    // Determine the profile picture URL or null if not available
    String? profilePicUrl = user?.photoURL;
    
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              
             
              
              title: Text(pageNames[widget.child.currentIndex], style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
            
              centerTitle: false,
              
              leading: Builder(
                builder: (context) {
                  return IconButton(
                icon: profilePicUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePicUrl),
                        radius: 16, // Adjust the size to fit your AppBar
                      )
                    : const Icon(Icons.account_circle_outlined, size: 28), // Default icon
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );}
              ),
            ),
            bottomSheet: MiniPlayerView(),
            
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.my_library_music),
                  activeIcon: Icon(Icons.my_library_music, size: 28),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    activeIcon: Icon(Icons.search, size: 28),
                    label: "Explore")
              ],
              currentIndex: widget.child.currentIndex,
              selectedFontSize: 14,
              iconSize: 23,
              selectedItemColor: Color.fromARGB(255, 8, 104, 187),
              unselectedItemColor: Colors.white,
              onTap: (index) {
                widget.child
                .goBranch(
                  index,
                  initialLocation: index == widget.child.currentIndex 
                  );
             
              },
              
            ),
            body: widget.child,
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
            UserAccountsDrawerHeader(
              accountName: Text(UserProfileService.userProfile.username ?? UserProfileService.userProfile.email!),
              accountEmail: null, // You can also display the user's email here if you want
              currentAccountPicture: profilePicUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(profilePicUrl, ),radius: 16,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey.shade800,
                      child: Icon(Icons.account_circle, size: 28),
                    ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 8, 104, 187),
              ),
            ),
                  ListTile(
                    title: const Text('Account Information'),
                    leading: Icon(Icons.account_box),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: const Text('Connected Music Accounts'),
                    leading: Icon(Icons.music_note),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectMusicServicesPage(showBackButton: true, showContinue: false,)));
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: const Text('Log out'),
                    leading: Icon(Icons.logout),
                    onTap: () async {
                      await UserProfileService.logout();
                      // Update the state of the app.
                      // ...
                    },
                  ),
                ],
              ),
            )));
  }

}
