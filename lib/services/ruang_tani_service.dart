import 'dart:math';
import 'package:flutter/foundation.dart';
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userLocation': userLocation,
        'timeText': timeText,
        'createdAt': createdAt.toIso8601String(),
        'postText': postText,
        'attachedImageLabel': attachedImageLabel,
        'imageUrl': imageUrl,
        'category': category,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'comments': comments,
      };

  factory RuangTaniPost.fromJson(Map<String, dynamic> json) => RuangTaniPost(
        id: json['id'] as String,
        userName: json['userName'] as String? ?? 'Petani TaniYuk',
        userLocation: json['userLocation'] as String? ?? 'Indonesia',
        timeText: json['timeText'] as String? ?? 'Baru saja',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        postText: json['postText'] as String? ?? '',
        attachedImageLabel: json['attachedImageLabel'] as String?,
        imageUrl: json['imageUrl'] as String?,
        category: json['category'] as String? ?? 'Diskusi',
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        isLiked: false,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
        comments: (json['comments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        imageColor: const Color(0xFF89D7B7),
      );
}

class RuangTaniService {
  static final ValueNotifier<int> postsNotifier = ValueNotifier<int>(0);
  static final List<RuangTaniPost> _posts = [];

  static List<RuangTaniPost> getPosts({String category = 'Semua', String searchQuery = ''}) {
    final list = <RuangTaniPost>[..._posts];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list.where((post) {
      final matchesCategory = category == 'Semua' || post.category == category;
      final matchesSearch = searchQuery.isEmpty ||
          post.postText.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.userName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.userLocation.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  static Stream<List<RuangTaniPost>> getPostsStream({String category = 'Semua', String searchQuery = ''}) {
    // Mendengarkan perubahan Cloud Firestore secara live
    return FirebaseService.firestore
        .collection('ruang_tani')
        .snapshots()
        .map((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final id = doc.id;
        final existingIdx = _posts.indexWhere((p) => p.id == id);

        final post = RuangTaniPost(
          id: id,
          userName: data['userName'] as String? ?? 'Petani TaniYuk',
          userLocation: data['userLocation'] as String? ?? 'Indonesia',
          timeText: 'Baru saja',
          createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
          postText: data['postText'] as String? ?? '',
          attachedImageLabel: data['attachedImageLabel'] as String? ?? (data['imageUrl'] != null ? '📷 Foto Kegiatan Pertanian' : null),
          imageUrl: data['imageUrl'] as String?,
          category: data['category'] as String? ?? 'Diskusi',
          likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
          isLiked: false,
          commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
          comments: (data['comments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          imageColor: const Color(0xFF89D7B7),
        );

        if (existingIdx == -1) {
          _posts.add(post);
        } else {
          _posts[existingIdx] = post;
        }
      }

      return getPosts(category: category, searchQuery: searchQuery);
    });
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
    postsNotifier.value++;

    // Sinkronkan data postingan LENGKAP (termasuk label & foto) ke Cloud Firestore ('ruang_tani')
    FirebaseService.syncPostToFirestore({
      'id': newPost.id,
      'userName': newPost.userName,
      'userLocation': newPost.userLocation,
      'postText': newPost.postText,
      'attachedImageLabel': newPost.attachedImageLabel,
      'imageUrl': newPost.imageUrl,
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
      postsNotifier.value++;

      FirebaseService.syncPostToFirestore({
        'id': post.id,
        'likeCount': post.likeCount,
      });
    }
  }

  static void addComment(String postId, String authorName, String commentText) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final formattedComment = '$authorName: $commentText';
      post.comments.add(formattedComment);
      post.commentCount = post.comments.length;
      postsNotifier.value++;

      FirebaseService.syncPostToFirestore({
        'id': post.id,
        'commentCount': post.commentCount,
        'comments': post.comments,
      });
    }
  }

  static void deletePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    postsNotifier.value++;
  }
}
