import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'des_controller.dart';

class FavoritesPage extends StatefulWidget {
  final User? currentUser;

  const FavoritesPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  AlleventsController _eventsController = AlleventsController();
  late Stream<QuerySnapshot> _favoritesStream;

  @override
  void initState() {
    super.initState();
    // Ensure there is a signed-in user before fetching favorites
    if (widget.currentUser != null) {
      _favoritesStream = _eventsController.getFavoritesStream(widget.currentUser?.uid ?? '');    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _favoritesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Check if there are no favorites
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No favorites yet.'),
            );
          }

          // Display the favorites
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Access the favorite item data
              var favoriteData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Display your favorite item UI here
              return ListTile(
                title: Text(favoriteData['itemName']),
                // Add other UI elements as needed
              );
            },
          );
        },
      ),
    );
  }
}
