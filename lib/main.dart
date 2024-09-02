import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/OnBoarding/Registration/PasswordSetupPage.dart';
import 'package:hypeclip/OnBoarding/Registration/registrationUsernameEmailPage.dart';
import 'package:hypeclip/OnBoarding/loginPage.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/Pages/ClipEditor/ClipEditor.dart';
import 'package:hypeclip/Pages/ConnectMusicServicesPage.dart';
import 'package:hypeclip/Pages/Explore/ConnectedAccounts.dart';
import 'package:hypeclip/Pages/Explore/GenericExplorePage.dart';
import 'package:hypeclip/Pages/Explore/UserPlaylists.dart';
import 'package:hypeclip/Pages/Explore/explore.dart';
import 'package:hypeclip/Pages/Explore/TrackList.dart';
import 'package:hypeclip/Pages/Explore/noConnectedAccounts.dart';
import 'package:hypeclip/Widgets/CreateNewPlaylistModal.dart';
import 'package:hypeclip/Pages/Library/ListOfPlaylists.dart';
import 'package:hypeclip/Pages/Library/ListOfTrackClips.dart';
import 'package:hypeclip/Pages/SongPlayer/SongPlayback.dart';
import 'package:hypeclip/Pages/home.dart';
import 'package:hypeclip/Pages/Library/library.dart';
import 'package:hypeclip/Services/UserProfileService.dart';
import 'package:hypeclip/Utilities/DeviceInfoManager.dart';
import 'package:hypeclip/firebase_options.dart';

Future<void> initUser() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    UserProfileService.setUser(
      user.uid,
      user.displayName ?? '',
      user.email ?? '',
      true,
    );
    await UserProfileService
        .fetchAndStoreConnectedMusicLibrariesFromFireStore();
    await UserProfileService.initMusicServicesForStorage();
    await UserProfileService.loadUserTrackClipPlaylistsFromPreferences();
  }
}

Future main() async {
  //main method is where the root of the application runs
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DeviceInfoManager().initDeviceId();
  await Future.delayed(const Duration(milliseconds: 3200));
  await initUser();
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    _router.refresh();
  });
  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: MyApp()));
  //run app takes in a root widget that displays on your device. The root widget is described by a class
}

final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/auth/login',
  routes: [
    GoRoute(
        path: '/songPlayer',
        name: 'songPlayer',
        pageBuilder: (context, state) {
          return NoTransitionPage(
              key: state.pageKey,
              child: SongPlayback(
                key: state.pageKey,
              ));
        }),
    GoRoute(
        path: '/clipEditor',
        name: 'clipEditor',
        pageBuilder: (context, state) {
          final bool showMiniOnExit =
              state.uri.queryParameters['fromMiniPlayer'] == 'true'
                  ? true
                  : false;
          return NoTransitionPage(
              key: state.pageKey,
              child: ClipEditor(
                key: state.pageKey,
                showMiniPlayerOnExit: showMiniOnExit,
              ));
        }),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          Home(key: state.pageKey, child: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  key: state.pageKey,
                  child: Library(
                    key: state.pageKey,
                  ));
            },
            routes: [
              GoRoute(
                  path: 'savedClips',
                  name: "library/savedClips",
                  pageBuilder: (context, state) {
                    return NoTransitionPage(
                        key: state.pageKey,
                        child: ListOfTrackClips(
                          key: state.pageKey,
                        ));
                  }),
              GoRoute(
                  path: 'clipPlaylists',
                  name: "library/clipPlaylists",
                  pageBuilder: (context, state) {
                    return NoTransitionPage(
                        key: state.pageKey,
                        child: ListOfPlaylists(
                          key: state.pageKey,
                        ));
                  },
                  routes: [
                    GoRoute(
                        path: 'playlist/:playlistName',
                        name: "library/clipPlaylists/playlist",
                        pageBuilder: (context, state) {
                          String playlistName =
                              state.pathParameters['playlistName'] ?? TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY;
                          return NoTransitionPage(
                              key: state.pageKey,
                              child: ListOfTrackClips(
                                key: state.pageKey,
                                playlistName: playlistName,
                              ));
                        }),
                        
                  ]),
            ],
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
              path: '/explore',
              pageBuilder: (context, state) {
                return NoTransitionPage(
                    key: state.pageKey,
                    child: Explore(
                      key: state.pageKey,
                    ));
              },
              routes: [
                GoRoute(
                  path: 'noAccountsConnected',
                  pageBuilder: (context, state) {
                    return NoTransitionPage(
                        key: state.pageKey,
                        child: NoConnectedAccounts(
                          key: state.pageKey,
                        ));
                  },
                ),
                GoRoute(
                  path: 'connectMusicServicesPage',
                  name: 'explore/connectMusicServicesPage',
                  pageBuilder: (context, state) {
                    return NoTransitionPage(
                        key: state.pageKey,
                        child: ConnectMusicServicesPage(
                          key: state.pageKey,
                          showBackButton: true,
                          showContinue: false,
                          showDescription: true,
                        ));
                  },
                ),
                GoRoute(
                    path: 'connectedAccounts',
                    name: 'explore/connectedAccounts',
                    pageBuilder: (context, state) {
                      return NoTransitionPage(
                          key: state.pageKey,
                          child: ConnectedAccounts(
                            key: state.pageKey,
                          ));
                    },
                    routes: [
                      GoRoute(
                          path: 'browseMusicPlatform',
                          name: 'explore/connectedAccounts/browseMusicPlatform',
                          pageBuilder: (context, state) {
                            // later change so that you can pass in any service
                            return NoTransitionPage(
                                key: state.pageKey,
                                child: GenericExplorePage(
                                    key: state.pageKey,
                                    service: MusicLibraryService.spotify));
                          },
                          routes: [
                            GoRoute(
                              path: 'userLikedSongs',
                              name:
                                  'explore/connectedAccounts/browseMusicPlatform/userLikedSongs',
                              pageBuilder: (context, state) {
                                // later change so that you can pass in any service
                                return NoTransitionPage(
                                    key: state.pageKey,
                                    child: TrackList(
                                      fetchLikedSongs: true,
                                    ));
                              },
                            ),
                            GoRoute(
                              path: 'userPlaylists',
                              name:
                                  'explore/connectedAccounts/browseMusicPlatform/userPlaylists',
                              pageBuilder: (context, state) {
                                // later change so that you can pass in any service
                                return NoTransitionPage(
                                    key: state.pageKey,
                                    child: UserPlaylistsPage());
                              },
                            ),
                            GoRoute(
                              path: 'userRecentlyPlayedTracks',
                              name:
                                  'explore/connectedAccounts/browseMusicPlatform/userRecentlyPlayedTracks',
                              pageBuilder: (context, state) {
                                // later change so that you can pass in any service
                                return NoTransitionPage(
                                    key: state.pageKey,
                                    child: TrackList(
                                      fetchRecentlyPlayedTracks: true,
                                    ));
                              },
                            ),
                          ]),
                    ]),
              ]),
        ])
      ],
    ),
    GoRoute(path: '/auth', builder: (context, state) => LoginPage(), routes: [
      GoRoute(
        path: 'login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => LoginPage(),
      ),
      GoRoute(
          path: 'register',
          name: 'register',
          builder: (BuildContext context, GoRouterState state) =>
              RegistrationUsernameEmailPage(),
          routes: [
            GoRoute(
                path: 'pass',
                name: 'register/pass',
                builder: (context, state) {
                  final String username =
                      state.uri.queryParameters['username'] ?? '';
                  // state.pathParameters['username'] ?? '';
                  final String email = state.uri.queryParameters['email'] ?? '';

                  return PasswordSetupPage(username: username, email: email);
                }),
            GoRoute(
                path: 'connectMusicServices',
                name: 'register/connectMusicServices',
                builder: (context, state) {
                  return ConnectMusicServicesPage(
                    showBackButton: false,
                    showContinue: true,
                  );
                })
          ])
    ]),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    //Check for display name as well since making dummy account for checking if email already exists automatically logs user in.
    final bool loggedIn =
        Auth().user != null && Auth().user!.displayName != null;
    // Check if the current location is attempting to access the registration page
    final bool isRegister = state.matchedLocation == '/auth/register';
    final bool isPassword =
        state.matchedLocation.startsWith('/auth/register/pass');
    final bool isConnectMusicLibraries =
        state.matchedLocation == '/auth/register/connectMusicServices';
    // If not logged in, redirect to the appropriate auth page based on the current location
    if (!loggedIn) {
      if (isRegister) {
        return '/auth/register';
      } else if (isPassword) {
        final String queryParams =
            '?${Uri(queryParameters: state.uri.queryParameters).query}';
        return '/auth/register/pass$queryParams';
      } else {
        return '/auth/login';
      }
    }
    // If logged in and trying to access auth pages, redirect to the home page
    if (loggedIn && (state.matchedLocation.startsWith('/auth'))) {
      if (isConnectMusicLibraries) {
        return '/auth/register/connectMusicServices';
      }
      return '/library';
    }
    // No redirection needed
    return null;
  },

  // if the user is logged in but still on the login page, send them to
  // the home page
);

class MyApp extends StatelessWidget {
  //Stateless widget == no dynamic data, just fixed elements
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //build describes a specific UI and is called everytime a rebuilding of that UI is needed.
    return MaterialApp.router(
      title: 'HypeClip',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color.fromARGB(255, 8, 104, 187),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
