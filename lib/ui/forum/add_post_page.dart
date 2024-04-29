import 'package:flutter/material.dart';
import 'package:greenneeds/ui/forum/forum_view_model.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final forumViewModel=Provider.of<ForumViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(onPressed: ()async{
            await forumViewModel.addPost(context, _titleController.text.trim(), _descriptionController.text.trim());
          }, icon:Icon(Icons.add))
        ],
        title: Text("Tambah Post"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("judul post", style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 5.0),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      hintText: "judul post",
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text("deskripsi post", style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 5.0),
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      hintText: "deskripsi post",
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
          if (forumViewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
