import 'package:flutter/material.dart';
import 'tips_trik_screen.dart';
import '../util/permission_helper.dart';
import '../util/media_picker_service.dart';
import '../util/live_camera_dialog.dart';

class RuangTaniPost {
  final String id;
  final String userName;
  final String userLocation;
  final String timeText;
  final String postText;
  final String? attachedImageLabel;
  final String? imageUrl;
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
    required this.postText,
    this.attachedImageLabel,
    this.imageUrl,
    required this.imageColor,
    required this.category,
    required this.likeCount,
    this.isLiked = false,
    required this.commentCount,
    required this.comments,
  });
}

class RuangTaniScreen extends StatefulWidget {
  const RuangTaniScreen({super.key});

  @override
  State<RuangTaniScreen> createState() => _RuangTaniScreenState();
}

class _RuangTaniScreenState extends State<RuangTaniScreen> {
  int _selectedChip = 0;
  final List<String> _categories = ['Semua', 'Diskusi', 'Tips', 'Panen'];
  String _searchQuery = '';

  final List<RuangTaniPost> _postsList = [
    RuangTaniPost(
      id: '1',
      userName: 'Pak Joko',
      userLocation: 'Bandung',
      timeText: '2 jam lalu',
      postText:
          'Alhamdulillah, padi tumbuh subur! Ada yang punya tips supaya hasil panen makin maksimal?',
      attachedImageLabel: '🌾 Lahan Padi Subur - Bandung',
      imageColor: const Color(0xFFDCFCE7),
      category: 'Diskusi',
      likeCount: 34,
      isLiked: false,
      commentCount: 8,
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
      postText:
          'Panen tomat pertama musim ini. Segar dan siap dipasarkan ke Pasar Tani!',
      attachedImageLabel: '🍅 Hasil Panen Tomat Segar',
      imageColor: const Color(0xFFFEE2E2),
      category: 'Panen',
      likeCount: 42,
      isLiked: true,
      commentCount: 12,
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
      postText:
          'Sharing pengalaman bikin pupuk kompos sendiri dari limbah jerami. Lebih hemat dan hasil tanah lebih gembur!',
      attachedImageLabel: '🍃 Pembuatan Pupuk Kompos',
      imageColor: const Color(0xFFFEF3C7),
      category: 'Tips',
      likeCount: 56,
      isLiked: false,
      commentCount: 19,
      comments: [
        'Pak Joko: Mantap mas, hemat biaya operasional lahan.',
      ],
    ),
  ];

  List<RuangTaniPost> get _filteredPosts {
    return _postsList.where((post) {
      final categoryFilter = _categories[_selectedChip];
      final matchesCategory = categoryFilter == 'Semua' || post.category == categoryFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          post.postText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.userLocation.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    final textController = TextEditingController();
    PickedMediaResult? attachedMedia;
    String attachedLocation = 'Surabaya';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Buat Postingan Baru',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Text area
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Bagikan cerita, kendala, atau tips pertanianmu...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Attached photo preview badge
                  if (attachedMedia != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          if (attachedMedia!.objectUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                attachedMedia!.objectUrl!,
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.image, color: Color(0xFF15803D)),
                              ),
                            )
                          else
                            const Icon(Icons.image_rounded, size: 24, color: Color(0xFF15803D)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Foto Terlampir',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  attachedMedia!.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF15803D)),
                            onPressed: () => setModalState(() => attachedMedia = null),
                          ),
                        ],
                      ),
                    ),

                  // Location badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF0369A1)),
                        const SizedBox(width: 6),
                        Text(
                          '📍 Lokasi: $attachedLocation',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0369A1), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Camera/Gallery Attach Button
                      IconButton(
                        icon: const Icon(Icons.photo_camera_outlined, color: Color(0xFF0F623F), size: 24),
                        tooltip: 'Lampirkan Foto',
                        onPressed: () {
                          _showPhotoSourceSelection(context, (selectedMedia) {
                            setModalState(() {
                              attachedMedia = selectedMedia;
                            });
                          });
                        },
                      ),
                      // Location Pin Button
                      IconButton(
                        icon: const Icon(Icons.location_on_outlined, color: Color(0xFF0F623F), size: 24),
                        tooltip: 'Sematkan Lokasi GPS',
                        onPressed: () {
                          setModalState(() {
                            attachedLocation = 'Surabaya (GPS Terdeteksi)';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lokasi GPS berhasil disematkan!')),
                          );
                        },
                      ),
                      const Spacer(),

                      // Kirim Button
                      ElevatedButton(
                        onPressed: () {
                          final text = textController.text.trim();
                          if (text.isEmpty && attachedMedia == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ketik cerita atau lampirkan foto terlebih dahulu!')),
                            );
                            return;
                          }

                          setState(() {
                            _postsList.insert(
                              0,
                              RuangTaniPost(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                userName: 'Budi Santoso',
                                userLocation: attachedLocation,
                                timeText: 'Baru saja',
                                postText: text.isNotEmpty ? text : 'Membagikan foto kegiatan pertanian.',
                                attachedImageLabel: attachedMedia?.fileName ?? '🌱 Foto Lahan Pertanian',
                                imageUrl: attachedMedia?.objectUrl,
                                imageColor: const Color(0xFFDCFCE7),
                                category: 'Diskusi',
                                likeCount: 0,
                                isLiked: false,
                                commentCount: 0,
                                comments: [],
                              ),
                            );
                          });

                          Navigator.pop(context);

                          MediaPickerService.sendSystemNotification(
                            title: '📢 Ruang Tani TaniYuk',
                            body: 'Postingan Anda berhasil dibagikan kepada petani lainnya!',
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Postingan berhasil dibagikan di Ruang Tani!'),
                              backgroundColor: Color(0xFF0F623F),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F623F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPhotoSourceSelection(BuildContext context, Function(PickedMediaResult) onPhotoSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Sumber Foto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Option 1: Kamera Live
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0F623F)),
                ),
                title: const Text('Ambil Foto (Kamera Live)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Gunakan kamera HP untuk memotret secara langsung', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  PermissionHelper.requestCameraPermission(
                    context,
                    onGranted: () async {
                      final pickedMedia = await showModalBottomSheet<PickedMediaResult>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const LiveCameraDialog(),
                      );
                      if (pickedMedia != null) {
                        onPhotoSelected(pickedMedia);
                      }
                    },
                  );
                },
              ),
              const Divider(),

              // Option 2: Galeri HP
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0284C7)),
                ),
                title: const Text('Pilih dari Galeri HP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Pilih berkas foto dari penyimpanan HP Anda', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  PermissionHelper.requestGalleryPermission(
                    context,
                    onGranted: () async {
                      final media = await MediaPickerService.pickImageFromGallery();
                      if (media != null) {
                        onPhotoSelected(media);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showCommentsModal(RuangTaniPost post) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Komentar (${post.comments.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (post.comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'Belum ada komentar. Jadi yang pertama berkomentar!',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: post.comments.length,
                        itemBuilder: (context, idx) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              post.comments[idx],
                              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Tulis balasan untuk petani...',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Color(0xFF0F623F)),
                        onPressed: () {
                          final cText = commentController.text.trim();
                          if (cText.isNotEmpty) {
                            setState(() {
                              post.comments.add('Budi Santoso: $cText');
                              post.commentCount++;
                            });
                            setModalState(() {
                              commentController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F623F),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ruang Tani',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Berbagi cerita, tumbuh bersama',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white),
            tooltip: 'Tips & Trik',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TipsTrikScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari cerita, tips, atau petani...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF0F623F)),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Categories Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_categories.length, (index) {
                      final isSelected = _selectedChip == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(_categories[index]),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0F623F),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF4B5563),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                          onSelected: (selected) {
                            setState(() {
                              _selectedChip = index;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Feed Post List
          Expanded(
            child: _filteredPosts.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada postingan ditemukan.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = _filteredPosts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildPostCard(post),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostBottomSheet(context);
        },
        backgroundColor: const Color(0xFF0F623F),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildPostCard(RuangTaniPost post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header User info
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF0F623F),
                child: Text(
                  post.userName.substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '${post.timeText} • ${post.userLocation}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  post.category,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Post Text
          Text(
            post.postText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // REAL Image Picture Container
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 200,
                color: post.imageColor,
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        post.attachedImageLabel ?? '📷 Foto Terlampir',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            )
          else if (post.attachedImageLabel != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 160,
                color: post.imageColor,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_rounded, color: Color(0xFF0F623F), size: 28),
                      const SizedBox(width: 8),
                      Text(
                        post.attachedImageLabel!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),

          // Actions Row
          Row(
            children: [
              // Like Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    post.isLiked = !post.isLiked;
                    if (post.isLiked) {
                      post.likeCount++;
                    } else {
                      post.likeCount--;
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 20,
                      color: post.isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.likeCount}',
                      style: TextStyle(
                        fontSize: 13,
                        color: post.isLiked ? Colors.red : Colors.grey,
                        fontWeight: post.isLiked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Comment Button
              GestureDetector(
                onTap: () => _showCommentsModal(post),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text('${post.commentCount}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              const Spacer(),

              // Share Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tautan postingan disalin! Siap dibagikan.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
