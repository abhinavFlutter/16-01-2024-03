import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'des_controller.dart';
class DescriptionPage extends StatefulWidget {
  final String documentId;
  final String categoryName;
  final String categoryImage;
  final List<DocumentSnapshot> allEventsData;
  final User? user;

  const DescriptionPage({
    Key? key,
    required this.documentId,
    required this.categoryName,
    required this.categoryImage,
    required this.allEventsData,
    required this.user,
  }) : super(key: key);

  @override
  _DescriptionPageState createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  List<int> selectedImageIndices = [];
  late User? user;
  Set<String> favoriteItems = Set<String>();
  final AlleventsController _alleventsController = AlleventsController();

  @override
  void initState() {
    super.initState();

    user = widget.user;

    // if (user != null) {
    //   // Fetch user's favorite items from Firestore
    //   _alleventsController
    //       .getFavoritesStream(user!.uid)
    //       .listen((QuerySnapshot snapshot) {
    //     setState(() {
    //       favoriteItems = Set<String>.from(
    //           snapshot.docs.map((DocumentSnapshot doc) => doc.id));
    //     });
    //   });
    // }

    for (int i = 0; i < widget.allEventsData.length; i++) {
      selectedImageIndices.add(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  for (final eventData in widget.allEventsData) ...[
                    _buildEventCard(eventData),
                    const SizedBox(height: 16.0),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(DocumentSnapshot eventData) {
    final pid = eventData['pid'];
    final price = eventData['price'];
    final pimages = eventData['pimage'] as List<dynamic>;
    final des = eventData['des'];

    final int productIndex = widget.allEventsData.indexOf(eventData);
    final String productId = eventData['pid'];
    bool isFavorite = favoriteItems.contains(productId);
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CollectionReference _userFavoritesCollection = _firestore.collection('userfavourite');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedImageIndices[productIndex] = 0;
                });
              },
              child: SizedBox(
                width: 370,
                height: 400,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: CachedNetworkImage(
                      imageUrl: pimages.isNotEmpty
                          ? pimages[selectedImageIndices[productIndex]] as String
                          : 'default_image_url',
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    // Toggle the favorite status
                    toggleFavorite(productId);

                    // Add or remove the item from the userfavourite collection
                    if (isFavorite) {
                      // Remove item from the collection
                      _userFavoritesCollection.doc(productId).delete();
                    } else {
                      // Add item to the collection
                      _userFavoritesCollection.doc(productId).set({
                        'pid': pid,
                        'price': price,
                        'pimage': pimages,
                        'des': des,
                        // Add other fields as needed
                      });
                    }
                  },
                ),

              ],
            ),
            const SizedBox(height: 8.0),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                "${price}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                "${des}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8.0),
            SizedBox(
              height: 120,
              child: SizedBox(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pimages.length,
                  itemBuilder: (context, imageIndex) {
                    final imageUrl = pimages[imageIndex] as String;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImageIndices[productIndex] = imageIndex;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleFavorite(String productId) {
    setState(() {
      if (favoriteItems.contains(productId)) {
        // Item is already in favorites, remove it
        favoriteItems.remove(productId);

      } else {
        // Item is not in favorites, add it
        favoriteItems.add(productId);

      }
    });
  }

}
