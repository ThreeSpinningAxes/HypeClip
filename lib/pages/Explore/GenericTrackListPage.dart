import 'package:flutter/material.dart';

class GenericTrackListPage extends StatefulWidget {
  final List items;
  final String title;


  const GenericTrackListPage({ super.key, required this.items, required this.title });

  @override
  _GenericTrackListPageState createState() => _GenericTrackListPageState();
}

class _GenericTrackListPageState extends State<GenericTrackListPage> {

  int totalItems = 0;
  List<dynamic> filteredItems = [];
  TextEditingController filter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}