import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

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
  static final List<RuangTaniPost> _posts = [
    RuangTaniPost(
      id: '1',
      userName: 'Pak Joko',
      userLocation: 'Bandung',
      timeText: '2 jam lalu',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      postText:
          'Alhamdulillah, padi tumbuh subur! Ada yang punya tips supaya hasil panen makin maksimal?',
      attachedImageLabel: '🌾 Lahan Padi Subur - Bandung',
      imageColor: const Color(0xFF89D7B7),
      category: 'Diskusi',
      likeCount: 34,
      isLiked: false,
      commentCount: 2,
      comments: [
        'Bu Siti: Gunakan pupuk organik cair di minggu ke-4 pak!',
        'Tani Muda: Pastikan irigasi lancar sebelum pemupukan.',
      ],
    ),
    RuangTaniPost(
      id: '2',
      userName: 'Bu Siti',
      userLocation: 'Lembang',
      timeText: '5 jam lalu',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      postText:
          'Panen tomat pertama musim ini. Segar dan siap dipasarkan ke Pasar Tani!',
      attachedImageLabel: '🍅 Hasil Panen Tomat Segar',
      imageColor: const Color(0xFFFEE2E2),
      category: 'Panen',
      likeCount: 42,
      isLiked: true,
      commentCount: 2,
      comments: [
        'Pak Joko: MasyaAllah hasilnya bagus sekali Bu Siti!',
        'Budi Santoso: Berapa harga per kg sekarang bu?',
      ],
    ),
    RuangTaniPost(
      id: '3',
      userName: 'Tani Muda',
      userLocation: 'Garut',
      timeText: '1 hari lalu',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      postText:
          'Sharing pengalaman bikin pupuk kompos sendiri dari limbah jerami. Lebih hemat dan hasil tanah lebih gembur!',
      attachedImageLabel: '🍃 Pembuatan Pupuk Kompos',
      imageColor: const Color(0xFFFEF3C7),
      category: 'Tips',
      likeCount: 56,
      isLiked: false,
      commentCount: 1,
      comments: [
        'Pak Joko: Mantap mas, hemat biaya operasional lahan.',
      ],
    ),
  ];

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
      userName: userName,
      userLocation: userLocation,
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
