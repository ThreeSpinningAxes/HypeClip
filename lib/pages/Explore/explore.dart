import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Pages/Explore/noConnectedAccounts.dart';
import 'package:hypeclip/Providers/musicServicesProvider.dart';
import 'package:hypeclip/Pages/Explore/ConnectedAccounts.dart';

class Explore extends ConsumerWidget {
  Explore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedMusicLibraries = ref.watch(musicServicesProvider);
    final page = connectedMusicLibraries.isEmpty
        ? NoConnectedAccounts()
        : ConnectedAccounts();

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: SafeArea(child: page),
        ),
      );
    
  }
}