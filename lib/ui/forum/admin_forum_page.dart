import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

import '../../model/Post.dart';
import '../admin/admin_screen.dart';
import 'forum_view_model.dart';
import 'package:badges/badges.dart' as badges;

class AdminForumPage extends StatefulWidget {
  const AdminForumPage({Key? key}) : super(key: key);

  @override
  State<AdminForumPage> createState() => _AdminForumPageState();
}

class _AdminForumPageState extends State<AdminForumPage> {
  @override
  Widget build(BuildContext context) {
    final forumViewModel = Provider.of<ForumViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_2),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AdminProfilePopUpWindow();
                },
              );
            },
          ),
        ],
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
                                borderRadius: BorderRadius.circular(20)),
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
                                            backgroundImage: post.photoUrl !=
                                                    null
                                                ? NetworkImage(post.photoUrl!)
                                                : const AssetImage(
                                                        'images/placeholder_profile.jpg')
                                                    as ImageProvider<Object>?,
                                            radius: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(post.name),
                                              Text(formatDateWithMonth(
                                                  post.date))
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: FutureBuilder<List<String>>(
                                      future: forumViewModel
                                          .getReportComments(post.uid),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container();
                                        } else {
                                          return PopupMenuButton(
                                            icon: badges.Badge(
                                              badgeContent: Text(snapshot
                                                  .data!.length
                                                  .toString()),
                                              child: Icon(Icons.more_vert),
                                            ),
                                            itemBuilder:
                                                (BuildContext context) {
                                              return [
                                                if (snapshot.data!.isNotEmpty)
                                                  PopupMenuItem(
                                                    value: 'option1',
                                                    child:
                                                        Text('lihat laporan'),
                                                    onTap: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return ReportCommentsPopup(
                                                            reportComments: snapshot.data!,
                                                            post: post,
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                PopupMenuItem(
                                                  value: 'option2',
                                                  child: Text('Delete post'),
                                                  onTap: () async {
                                                    await forumViewModel
                                                        .disablePost(post.uid);
                                                  },
                                                ),
                                              ];
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(post.title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
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
    );
  }

  void _showPostDetailsDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(post.title, style: TextStyle(fontWeight: FontWeight.bold)),
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
                    SizedBox(width: 10),
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

class ReportCommentsPopup extends StatelessWidget {
  final List<String> reportComments;
  final Post post;

  ReportCommentsPopup({
    required this.reportComments,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final forumViewModel = Provider.of<ForumViewModel>(context);
    return AlertDialog(
      title: Text("List laporan post"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (String comment in reportComments)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(comment),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        ),
      ],
    );
  }
}

