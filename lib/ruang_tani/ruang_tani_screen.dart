import 'dart:convert';
import 'package:flutter/material.dart';
import 'tips_trik_screen.dart';
import '../util/permission_helper.dart';
import '../util/media_picker_service.dart';
import '../akun/notifikasi.dart';
import '../services/ruang_tani_service.dart';
import '../services/app_store.dart';
import '../services/geocoding_places_service.dart';

class RuangTaniScreen extends StatefulWidget {
  const RuangTaniScreen({super.key});

  @override
  State<RuangTaniScreen> createState() => _RuangTaniScreenState();
}

class _RuangTaniScreenState extends State<RuangTaniScreen> {
  int _selectedChip = 0;
  final List<String> _categories = ['Semua', 'Diskusi', 'Keluh Kesah', 'Berita', 'Tips', 'Panen'];
  String _searchQuery = '';

  List<RuangTaniPost> get _filteredPosts {
    final categoryFilter = _categories[_selectedChip];
    return RuangTaniService.getPosts(category: categoryFilter, searchQuery: _searchQuery);
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    final pageContext = context;
    final messenger = ScaffoldMessenger.of(context);
    final textController = TextEditingController();
    PickedMediaResult? attachedMedia;
    String attachedLocation = AppStore.instance.profile.location;
    String selectedCategory = 'Diskusi';

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
                        color: const Color(0xFF89D7B7),
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
                                errorBuilder: (c, e, s) => const Icon(Icons.image, color: Color(0xFF428475)),
                              ),
                            )
                          else
                            const Icon(Icons.image_rounded, size: 24, color: Color(0xFF428475)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Foto Terlampir',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF428475), fontWeight: FontWeight.bold),
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
                            icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF428475)),
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

                  // Kategori postingan
                  const Text(
                    'Kategori',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Diskusi', 'Keluh Kesah', 'Berita', 'Tips', 'Panen'].map((category) {
                      final isSelected = selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: const Color(0xFF132E25),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        onSelected: (_) => setModalState(() => selectedCategory = category),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Camera/Gallery Attach Button
                      IconButton(
                        icon: const Icon(Icons.photo_camera_outlined, color: Color(0xFF132E25), size: 24),
                        tooltip: 'Lampirkan Foto',
                        onPressed: () {
                          _showPhotoSourceSelection(pageContext, (selectedMedia) {
                            setModalState(() {
                              attachedMedia = selectedMedia;
                            });
                          });
                        },
                      ),
                      // Location Pin Button
                      IconButton(
                        icon: const Icon(Icons.location_on_outlined, color: Color(0xFF132E25), size: 24),
                        tooltip: 'Sematkan Lokasi GPS',
                        onPressed: () async {
                          final realLoc = await GeocodingPlacesService.getCurrentUserAddress();
                          setModalState(() {
                            attachedLocation = realLoc;
                          });
                          messenger.showSnackBar(
                            SnackBar(content: Text('Lokasi GPS ($realLoc) berhasil disematkan!')),
                          );
                        },
                      ),
                      const Spacer(),

                      // Kirim Button
                      ElevatedButton(
                        onPressed: () {
                          final text = textController.text.trim();
                          if (text.isEmpty && attachedMedia == null) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Ketik cerita atau lampirkan foto terlebih dahulu!')),
                            );
                            return;
                          }

                          final profile = AppStore.instance.profile;
                          final hasMedia = attachedMedia != null;
                          final mediaLabel = hasMedia
                              ? (attachedMedia!.fileName.isNotEmpty ? attachedMedia!.fileName : '📷 Foto Kegiatan Pertanian.jpg')
                              : null;
                          String? mediaUrl;
                          if (hasMedia) {
                            if (attachedMedia!.bytes != null && attachedMedia!.bytes!.isNotEmpty) {
                              mediaUrl = 'data:image/jpeg;base64,${base64Encode(attachedMedia!.bytes!)}';
                            } else if (attachedMedia!.objectUrl != null && !attachedMedia!.objectUrl!.startsWith('blob:')) {
                              mediaUrl = attachedMedia!.objectUrl;
                            }
                          }

                          setState(() {
                            RuangTaniService.createPost(
                              userName: profile.name,
                              userLocation: attachedLocation,
                              postText: text.isNotEmpty ? text : 'Membagikan foto kegiatan pertanian.',
                              attachedImageLabel: mediaLabel,
                              imageUrl: mediaUrl,
                              attachedBytes: attachedMedia?.bytes,
                              category: selectedCategory,
                            );
                          });

                          Navigator.pop(context);

                          MediaPickerService.sendSystemNotification(
                            title: '📢 Ruang Tani TaniYuk',
                            body: 'Postingan Anda berhasil dibagikan kepada petani lainnya!',
                          );

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Postingan berhasil dibagikan di Ruang Tani!'),
                              backgroundColor: Color(0xFF132E25),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132E25),
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
    final pageContext = context;
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
                    color: Color(0xFF89D7B7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF132E25)),
                ),
                title: const Text('Ambil Foto (Kamera Live)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Gunakan kamera HP untuk memotret secara langsung', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  PermissionHelper.requestCameraPermission(
                    pageContext,
                    onGranted: () async {
                      final pickedMedia = await MediaPickerService.pickImageFromCamera();
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
                    pageContext,
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
                        icon: const Icon(Icons.send_rounded, color: Color(0xFF132E25)),
                        onPressed: () {
                          final cText = commentController.text.trim();
                          if (cText.isNotEmpty) {
                            final myName = AppStore.instance.profile.name;
                            RuangTaniService.addComment(post.id, myName, cText);
                            commentController.clear();
                            setModalState(() {});
                            setState(() {});
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
      backgroundColor: const Color(0xFFFFF4E1),
      appBar: AppBar(
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
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
              );
            },
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
                    suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF132E25)),
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
                          selectedColor: const Color(0xFF132E25),
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
            child: StreamBuilder<List<RuangTaniPost>>(
              stream: RuangTaniService.getPostsStream(
                category: _categories[_selectedChip],
                searchQuery: _searchQuery,
              ),
              builder: (context, snapshot) {
                final posts = snapshot.data ?? _filteredPosts;

                if (posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF89D7B7).withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.forum_outlined,
                              size: 54,
                              color: Color(0xFF132E25),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum Ada Postingan Komunitas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Jadilah yang pertama berbagi berita, tips, atau keluh kesah pertanian Anda di Ruang Tani!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showCreatePostBottomSheet(context),
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: const Text('Buat Postingan Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF132E25),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildPostCard(post),
                    );
                  },
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
        backgroundColor: const Color(0xFF132E25),
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
                backgroundColor: const Color(0xFF132E25),
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
                  color: const Color(0xFF89D7B7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  post.category,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF428475), fontWeight: FontWeight.bold),
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
          if (post.attachedBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 200,
                color: post.imageColor,
                child: Image.memory(
                  post.attachedBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 200,
                color: post.imageColor,
                child: post.imageUrl!.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(post.imageUrl!.split(',').last),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Center(
                          child: Text(
                            post.attachedImageLabel ?? '📷 Foto Terlampir',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : Image.network(
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
                      const Icon(Icons.image_rounded, color: Color(0xFF132E25), size: 28),
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
                    RuangTaniService.toggleLike(post.id);
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
