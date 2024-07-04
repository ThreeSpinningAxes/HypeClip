import 'package:flutter/material.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';

class GenericExplorePage extends StatefulWidget {
  final MusicLibraryService service;
  const GenericExplorePage({ Key? key, required this.service }) : super(key: key);

  @override
  _GenericExplorePageState createState() => _GenericExplorePageState();
}

class _GenericExplorePageState extends State<GenericExplorePage> {

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('explore',)),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            SizedBox(height: 20,),
             SearchBar(controller: searchController, hintText: 'Search for any song', leading: Icon(Icons.search_outlined),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
          ],
          
        ),
      ),
    );
  }
}