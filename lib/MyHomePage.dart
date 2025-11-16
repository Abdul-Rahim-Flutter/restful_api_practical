import 'package:flutter/material.dart';
import 'package:restful_api_practical/ApiService.dart';
import 'package:restful_api_practical/ErrorResponse.dart';
import 'package:restful_api_practical/formPage.dart';

class Myhomepage extends StatefulWidget {
  const Myhomepage({super.key});

  @override
  State<Myhomepage> createState() => _MyhomepageState();
}

class _MyhomepageState extends State<Myhomepage> {
  List<dynamic> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMore = true;

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      //here we have got the posts from the api service, and stored it in posts variable
      final posts = await ApiService().fetchPosts(_currentPage, _itemsPerPage);
      print('Loaded posts: ${posts.length}');
      setState(() {
        //_posts = posts;  //for replacing the old posts with new posts
        _posts.addAll(posts); //for adding new posts to the old posts
        _currentPage++; //increment page for next fetch
        _hasMore =
            posts.length == _itemsPerPage; //check if more posts are available
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      final message = e is ErrorResponse ? e.message : 'An error occurred';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts')),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Formpage()),
          );
        },
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Column(
              children: [
                Center(child: Text('An error occurred while fetching posts.')),
                SizedBox(height: 20),
                ElevatedButton(onPressed: _loadPosts, child: Text('Retry')),
              ],
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return ListTile(
                        title: Text(post['title']),
                        subtitle: Text(post['body']),
                      );
                    },
                  ),
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  //currently, if there are no more posts, the button will be disabled,
                  //the current value of hasMore is true, the loadPost logic is triggered which increments the page number
                  onPressed: _hasMore ? _loadPosts : null,
                  child: Text(_hasMore ? 'Load More' : 'No More Posts'),
                ),

                SizedBox(height: 10),
              ],
            ),
    );
  }
}
