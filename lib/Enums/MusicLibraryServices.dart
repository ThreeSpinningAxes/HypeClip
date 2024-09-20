import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

SvgPicture getSVGIcon(MusicLibraryService service) {
  switch (service) {
    case MusicLibraryService.spotify:
      return SvgPicture.asset(
        'assets/Spotify_Icon_RGB_Green.svg',
        width: 40,
      );
    case MusicLibraryService.youtubeMusic:
      return SvgPicture.asset(
        'assets/app_icon_music_round_192.svg',
        width: 40,
      );
    case MusicLibraryService.appleMusic:
      return SvgPicture.asset(
        'assets/appleMusicLogo/standard.svg',
        width: 40,
      );
    default:
      return SvgPicture.asset(
        'assets/Spotify_Icon_RGB_Green.svg',
        width: 40,
      );
  }
}

enum MusicLibraryService {
  spotify,
  youtubeMusic,
  appleMusic,
  amazonMusic,
  tidal,
  deezer,
  pandora,
  soundCloud,
  googlePlayMusic,
  napster,
}
class MusicLibraryServiceTile extends StatelessWidget {
  final MusicLibraryService service;
  final void Function()? onTap;
  final Widget trailing;


  const MusicLibraryServiceTile({
    super.key,
    required this.service,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: getSVGIcon(service),
      trailing: trailing,
      title: Text(service.name, style: const TextStyle(color: Colors.white, ),),
      onTap: () {
        onTap?.call();
      },
    );
  }
}
