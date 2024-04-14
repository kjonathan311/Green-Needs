
//search result food provider
class SearchFoodProvider {
  final String uid;
  final String title;
  final double distance;
  final double? rating;
  final String? photoUrl;

  SearchFoodProvider({
    required this.uid,
    required this.title,
    required this.distance,
    this.rating,
    this.photoUrl,
  });
}
