import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:restful_api_practical/ErrorResponse.dart';

class ApiService {
  // //get request to fetch posts
  // Future<List<dynamic>> fetchPosts() async {
  //   try{
  //     final response = await http.get(Uri.parse(baseUrl));
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     await ErrorHandler.handle(null, response);
  //     return [];
  //   }
  //   }catch(e){
  //     await ErrorHandler.handle(e, null);
  //     return [];
  //   }

  // }
  static const String baseUrl = 'https://gorest.co.in/public/v2/posts';

  //creating of a cache manager instance
  final CacheManager _cacheManager = DefaultCacheManager();

  //get request to fetch posts
  Future<List<dynamic>> fetchPosts(int page, int limit) async {
    try {
      //try to load the response from cache
      final fileInfo = await _cacheManager.getFileFromCache(
        '$baseUrl?page=$page&limit=$limit',
      );

      //checks whether the cached file is available and valid
      if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
        //read the saved file as raw bytes
        final cachedData = await fileInfo.file.readAsBytes();
        print("Cached data $cachedData");

        //convert the raw bytes to readable JSON format
        final decode = jsonDecode(utf8.decode(cachedData));
        print('Decoded Cached Posts: $decode');
        return decode;
      }
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&limit=$limit'),
        //for security issues, we are going to add Authorization header
        headers: {
          'Authorization':
              'Bearer 4f4028a124a3fc989921b366248f23de7de752db7bb7270153b66bd0133c0d46',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        //store the response in cache for future use
        await _cacheManager.putFile(
          '$baseUrl?page=$page&limit=$limit',
          response.bodyBytes,
          maxAge: Duration(seconds: 50),
        );

        print('Decoded Posts: ${response.body}');
        return jsonDecode(response.body);
      } else {
        await ErrorHandler.handle(null, response);
        return [];
      }
    } catch (e) {
      await ErrorHandler.handle(e, null);
      return [];
    }
  }

  //post request to create a post
  Future<void> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization':
            'Bearer 4f4028a124a3fc989921b366248f23de7de752db7bb7270153b66bd0133c0d46',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'body': body}),
    );
    if (response.statusCode != 201) {
      //throw Exception('Failed to create post');
      await ErrorHandler.handle(null, response);
    } else {
      print('Sending: title=$title, body=$body');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  //I am going to add some other features too.
}
