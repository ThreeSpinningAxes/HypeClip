import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/OnBoarding/Registration/PasswordSetupPage.dart';
import 'package:hypeclip/OnBoarding/Registration/connectMusicLibrariesRegistrationPage.dart';

import 'package:hypeclip/OnBoarding/Registration/registrationUsernameEmailPage.dart';
import 'package:hypeclip/OnBoarding/loginPage.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/Pages/ConnectMusicServicesPage.dart';
import 'package:hypeclip/Pages/Explore/ConnectedAccounts.dart';
import 'package:hypeclip/Pages/Explore/GenericExplorePage.dart';
import 'package:hypeclip/Pages/Explore/explore.dart';
import 'package:hypeclip/Pages/Explore/likedSongs.dart';
import 'package:hypeclip/Pages/Explore/noConnectedAccounts.dart';
import 'package:hypeclip/Pages/home.dart';
import 'package:hypeclip/Pages/library.dart';
import 'package:hypeclip/firebase_options.dart';

Future main() async {
  //main method is where the root of the application runs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    _router.refresh();
  });
  runApp(const ProviderScope(child:  MyApp()));
  //run app takes in a root widget that displays on your device. The root widget is described by a class
}

final _shellNavigatorKey = GlobalKey<NavigatorState>();


final GoRouter _router = GoRouter(
  initialLocation: '/auth/login',

  routes: [
    StatefulShellRoute.indexedStack(

      builder: (context, state, navigationShell) => Home(key: state.pageKey, child: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) {
              return NoTransitionPage(key: state.pageKey, child: Library(key: state.pageKey,));
            },
          ),
        ]),
        StatefulShellBranch(routes: <RouteBase>[
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) {
              return NoTransitionPage(key: state.pageKey, child: Explore(key: state.pageKey,));
              },
            routes: [
              GoRoute(
              path: 'noAccountsConnected',
              pageBuilder: (context, state) {
                return NoTransitionPage(key: state.pageKey, child: NoConnectedAccounts(key: state.pageKey,));
                },
            ),
               GoRoute(
                  path: 'connectMusicServicesPage',
                  name: 'explore/connectMusicServicesPage',
                  pageBuilder: (context, state) {
                    return NoTransitionPage(key: state.pageKey, child: ConnectMusicServicesPage(key: state.pageKey));
                  },
                ),
                   GoRoute(
                  path: 'connectedAccounts',
                  name: 'explore/connectedAccounts',
                  pageBuilder: (context, state) {
                    return NoTransitionPage(key: state.pageKey, child: ConnectedAccounts(key: state.pageKey,));
                  },
                  routes: [
                     GoRoute(
                      path: 'browseMusicPlatform',
                      name: 'explore/connectedAccounts/browseMusicPlatform',
                      pageBuilder: (context, state) {
                        // later change so that you can pass in any service
                        return NoTransitionPage(key: state.pageKey, child: GenericExplorePage(key: state.pageKey, service: MusicLibraryService.spotify));
                      },
                      routes: [
                        GoRoute(
                          path: 'userLikedSongs',
                          name: 'explore/connectedAccounts/browseMusicPlatform/userLikedSongs',
                          pageBuilder: (context, state) {
                            // later change so that you can pass in any service
                            return NoTransitionPage(key: state.pageKey, child: LikedSongs());
                          },
                        ),
                      ]
                    ),
                  ]
                ),
            ]
          ),

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
                  return ConnectMusicLibrariesRegistrationPage(
                    addSkipButton: true,
                    addBackButton: false,
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
