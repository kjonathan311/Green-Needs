import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

import '../../model/Post.dart';
import 'forum_view_model.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  @override
  Widget build(BuildContext context) {
    final forumViewModel = Provider.of<ForumViewModel>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
      ),
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: StreamBuilder<List<Post>>(
                  stream: forumViewModel.postStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    final posts = snapshot.data ?? [];
                    if (posts.isEmpty) {
                      return Center(child: Text('Tidak ada postingan.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return GestureDetector(
                          onTap: () {
                            _showPostDetailsDialog(context, post);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20)
                            ),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: post.photoUrl != null
                                                ? NetworkImage(post.photoUrl!)
                                                : const AssetImage('images/placeholder_profile.jpg')
                                            as ImageProvider<Object>?,
                                            radius: 20,
                                          ),
                                          SizedBox(width:10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(post.name),
                                              Text(formatDateWithMonth(post.date))
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: PopupMenuButton(
                                      icon: Icon(Icons.more_vert),
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          if(post.uidUser!=user!.uid)
                                          PopupMenuItem(
                                            value: 'option1',
                                            child: Text('lapor post'),
                                            onTap: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return ReportPopUpWindow(uid: post.uid, post: post);
                                                },
                                              );
                                            },
                                          ),
                                          if(post.uidUser==user!.uid)
                                            PopupMenuItem(
                                              value: 'option2',
                                              child: Text('Delete post'),
                                              onTap: () async{
                                                await forumViewModel.disablePost(post.uid);
                                              },
                                            ),

                                        ];
                                      },
                                    ),
                                  )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(post.title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/forum/add");
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showPostDetailsDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(post.title,style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.photoUrl != null
                          ? NetworkImage(post.photoUrl!)
                          : const AssetImage('images/placeholder_profile.jpg')
                      as ImageProvider<Object>?,
                      radius: 20,
                    ),
                    SizedBox(width:10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.name),
                        Text(formatDateWithMonth(post.date))
                      ],
                    )
                  ],
                ),
                SizedBox(height: 10),
                Text(post.description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}


class ReportPopUpWindow extends StatefulWidget {
  final Post post;
  final String uid;
  const ReportPopUpWindow({Key? key, required this.uid, required this.post}) : super(key: key);

  @override
  State<ReportPopUpWindow> createState() => _ReportPopUpWindowState();
}

class _ReportPopUpWindowState extends State<ReportPopUpWindow> {
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ForumViewModel>(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Lapor post ini",
                      style: Theme.of(context).textTheme.titleLarge!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    hintText: "alasan",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: ()async{
          await viewModel.reportPost(
            context,
            widget.post,
            _contentController.text.trim(),
          );
        }, child: Text("Submit"))
      ],
    );
  }
}