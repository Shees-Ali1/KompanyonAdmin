import 'package:admin_panel_komp/widgets/colors.dart';
import 'package:admin_panel_komp/widgets/custom_buuton.dart';
import 'package:admin_panel_komp/widgets/custom_text.dart';
import 'package:admin_panel_komp/sidebar_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class Read extends StatefulWidget {
  const Read({super.key});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  Future<void> _addArticle() async {
    if (_titleController.text.isEmpty ||
        _headlineController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('articles').add({
        'title': _titleController.text,
        'headline': _headlineController.text,
        'content': _contentController.text,
        'imageUrl': _imageUrlController.text,
        'timestamp': DateTime.now(),
      });

      _titleController.clear();
      _headlineController.clear();
      _contentController.clear();
      _imageUrlController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article published successfully')),
      );
    } catch (e) {
      print('Error publishing article: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error publishing article')),
      );
    }
  }

  final SidebarController sidebarController = Get.put(SidebarController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width < 380
                ? 5
                : width < 425
                    ? 15 // You can specify the width for widths less than 425
                    : width < 768
                        ? 20 // You can specify the width for widths less than 768
                        : width < 1024
                            ? 70 // You can specify the width for widths less than 1024
                            : width <= 1440
                                ? 60
                                : width > 1440 && width <= 2550
                                    ? 60
                                    : 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Get.width < 768
                  ? GestureDetector(
                      onTap: () {
                        sidebarController.showsidebar.value = true;
                      },
                      child: SvgPicture.asset(
                        'assets/images/drawernavigation.svg',
                        color: primaryColorKom,
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 20,
              ),
              const AsulCustomText(
                text: 'Add New Article',
                fontsize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: primaryColorKom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColorKom),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColorKom),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _headlineController,
                decoration: InputDecoration(
                  labelText: 'Headline',
                  labelStyle: const TextStyle(color: primaryColorKom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColorKom),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColorKom),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: const TextStyle(color: primaryColorKom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: const TextStyle(color: primaryColorKom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColorKom),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColorKom),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Publish Article',
                onPressed: _addArticle,
                height: 38,
                width: 150,
              ),
              const SizedBox(height: 24),
              const AsulCustomText(
                text: 'Recent Articles',
                fontsize: 22,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('articles')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error fetching articles');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final articles = snapshot.data!.docs;
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final articleData =
                          articles[index].data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleDetails(
                                articleData: articleData,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (articleData['imageUrl'] != null)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    articleData['imageUrl'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            articleData['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            articleData['headline'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          try {
                                            await _firestore
                                                .collection('articles')
                                                .doc(articles[index].id)
                                                .delete();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Article deleted successfully'),
                                              ),
                                            );
                                          } catch (e) {
                                            print('Error deleting article: $e');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Error deleting article'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.redAccent), // Add a red delete icon
                                              const SizedBox(width: 8), // Add spacing between the icon and the text
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.redAccent, // Match the icon color
                                                  fontWeight: FontWeight.bold, // Bold text for emphasis
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      articleData['content'],
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ArticleDetails(
                                              articleData: articleData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Read More...',
                                        style: TextStyle(color: primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticleDetails extends StatelessWidget {
  final Map<String, dynamic> articleData;

  const ArticleDetails({required this.articleData, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(articleData['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show the image if available
              if (articleData['imageUrl'] != null)
                Image.network(articleData['imageUrl']),
              SizedBox(height: 16),
              // Show the headline
              Text(
                articleData['headline'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Show the full article content
              Text(articleData['content']),
            ],
          ),
        ),
      ),
    );
  }
}
