import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class RuangTaniPost {
  final String id;
  final String userName;
  final String userLocation;
  final String timeText;
  final DateTime createdAt;
  final String postText;
  final String? attachedImageLabel;
  final String? imageUrl;
  final Uint8List? attachedBytes;
  final Color imageColor;
  final String category;
  int likeCount;
  bool isLiked;
  int commentCount;
  List<String> comments;

  RuangTaniPost({
    required this.id,
    required this.userName,
    required this.userLocation,
    required this.timeText,
    required this.createdAt,
    required this.postText,
    this.attachedImageLabel,
    this.imageUrl,
    this.attachedBytes,
    required this.imageColor,
    required this.category,
    required this.likeCount,
    this.isLiked = false,
    required this.commentCount,
    required this.comments,
  });
}

class RuangTaniService {
  // Daftar postingan nyata pengguna (bebas data dummy statis)
  static final List<RuangTaniPost> _posts = [];

  static List<RuangTaniPost> getPosts({String category = 'Semua', String searchQuery = ''}) {
    return _posts.where((post) {
      final matchesCategory = category == 'Semua' || post.category == category;
      final matchesSearch = searchQuery.isEmpty ||
          post.postText.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.userName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.userLocation.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  static RuangTaniPost createPost({
    required String userName,
    required String userLocation,
    required String postText,
    String? attachedImageLabel,
    String? imageUrl,
    Uint8List? attachedBytes,
    required String category,
  }) {
    final newPost = RuangTaniPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: userName.isEmpty ? 'Petani TaniYuk' : userName,
      userLocation: userLocation.isEmpty ? 'Indonesia' : userLocation,
      timeText: 'Baru saja',
      createdAt: DateTime.now(),
      postText: postText,
      attachedImageLabel: attachedImageLabel,
      imageUrl: imageUrl,
      attachedBytes: attachedBytes,
      imageColor: const Color(0xFF89D7B7),
      category: category,
      likeCount: 0,
      isLiked: false,
      commentCount: 0,
      comments: [],
    );

    _posts.insert(0, newPost);

    // Otomatis sinkronkan postingan baru ke Cloud Firestore ('ruang_tani')
    FirebaseService.syncPostToFirestore({
      'id': newPost.id,
      'userName': newPost.userName,
      'userLocation': newPost.userLocation,
      'postText': newPost.postText,
      'category': newPost.category,
      'createdAt': newPost.createdAt.toIso8601String(),
      'likeCount': 0,
      'commentCount': 0,
    });

    return newPost;
  }

  static void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      post.isLiked = !post.isLiked;
      if (post.isLiked) {
        post.likeCount++;
      } else {
        post.likeCount = max(0, post.likeCount - 1);
      }
    }
  }

  static void addComment(String postId, String authorName, String commentText) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final formattedComment = '$authorName: $commentText';
      post.comments.add(formattedComment);
      post.commentCount = post.comments.length;
    }
  }

  static void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
  }
}
