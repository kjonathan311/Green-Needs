
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/Post.dart';
import '../consumer/profile/consumer_profile_view_model.dart';
import '../provider/profile/food_provider_profile_view_model.dart';
import '../utils.dart';

class ForumViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<Post>> postStream() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference postCollectionRef = _firestore.collection('posts');

      final initialSnapshot = await postCollectionRef.get();

      if (initialSnapshot.docs.isNotEmpty) {
        await for (QuerySnapshot snapshot in postCollectionRef.snapshots()) {
          List<Post> posts = [];
          for (QueryDocumentSnapshot doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            if(data['status']==true){
              Post post = Post(
                uid: doc.id,
                title: data['title'],
                description: data['description'],
                name: data['name'],
                photoUrl: data['photoUrl'],
                status: data['status'],
                uidUser: data['uidUser'],
                date: (data['date'] as Timestamp).toDate(),
              );
              posts.add(post);
            }
          }
          posts.sort((a, b) => b.date.compareTo(a.date));
          yield posts;
        }
      } else {
        yield [];
      }
    } else {
      yield [];
    }
  }

  Future<void> addPost(BuildContext context, String title, String description) async {
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {
      if (title.isEmpty || description.isEmpty) {
        showCustomSnackBar(
            context, "Semua field perlu diisi.", color: Colors.red);

        _isLoading = false;
        notifyListeners();
        return;
      }

      try {
        final foodProviderViewModel = Provider.of<FoodProviderProfileViewModel>(
            context,listen: false);
        final consumerViewModel = Provider.of<ConsumerProfileViewModel>(
            context,listen: false);
        await foodProviderViewModel.fetchProfile();
        await consumerViewModel.fetchProfile();
        if (foodProviderViewModel.foodProviderProfile != null) {
          Map<String, dynamic> postData = {
            'title': title,
            'description': description,
            'name': foodProviderViewModel.foodProviderProfile?.name,
            if(foodProviderViewModel.foodProviderProfile?.photoUrl !=
                null)'photoUrl': foodProviderViewModel.foodProviderProfile
                ?.photoUrl,
            'uidUser': foodProviderViewModel.foodProviderProfile?.uid,
            'date': Timestamp.fromDate(DateTime.now()),
            'status': true
          };

          await _firestore.collection('posts').add(postData);
        } else if (consumerViewModel.consumerProfile != null) {
          Map<String, dynamic> postData = {
            'title': title,
            'description': description,
            'name': consumerViewModel.consumerProfile?.name,
            if(consumerViewModel.consumerProfile?.photoUrl !=
                null)'photoUrl': consumerViewModel.consumerProfile
                ?.photoUrl,
            'uidUser': consumerViewModel.consumerProfile?.uid,
            'date': Timestamp.fromDate(DateTime.now()),
            'status': true
          };

          await _firestore.collection('posts').add(postData);
        }

        Navigator.pop(context);
      } catch (e) {
        print(e);
        _isLoading = false;
        notifyListeners();
        return;
      }
      _isLoading = false;
      notifyListeners();
      return;
    }
  }

  Future<int> getReportsLength(String uidPost) async {
    QuerySnapshot reportSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(uidPost)
        .collection('reports')
        .get();

    return reportSnapshot.docs.length;
  }

  Future<List<String>> getReportComments(String uidPost) async {
    QuerySnapshot reportSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(uidPost)
        .collection('reports')
        .get();

    List<String> comments = [];
    reportSnapshot.docs.forEach((doc) {
      comments.add(doc['comment']);
    });

    return comments;
  }
  Future<void> reportPost(BuildContext context,Post post,String comment)async{
    User? user = _auth.currentUser;

    if (user == null) {
      return;
    }
    QuerySnapshot reportSnapshot = await _firestore
        .collection('posts')
        .doc(post.uid)
        .collection('reports')
        .where('uidUser', isEqualTo: user.uid)
        .get();

    if (reportSnapshot.docs.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Post Sudah Dilaporkan"),
            content: Text("Anda telah melaporkan postingan ini."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }
    if (comment.isEmpty) {
      showCustomSnackBar(context, "Semua field perlu diisi.", color: Colors.red);
      return;
    }
    try {
      await _firestore..collection('posts').doc(post.uid).collection('reports').add({
        'comment': comment,
        'uidUser': user.uid,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Post Terlapor"),
            content: Text("Post ini anda telah lapor."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showCustomSnackBar(context, "Error: $e", color: Colors.red);
    }
  }

  Future<void> disablePost(String uid)async{
    await _firestore.collection('posts').doc(uid).set({
      'status':false
    },SetOptions(merge: true));
  }
}
