import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../data/post_model.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});
  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  Uint8List? _image;
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post'), actions: [TextButton(onPressed: _isPosting || _contentController.text.isEmpty ? null : _post, child: _isPosting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Post'))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _contentController, maxLines: 6, decoration: const InputDecoration(hintText: 'Share your cleanup story...', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
        if (_image != null) Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_image!, height: 200, width: double.infinity, fit: BoxFit.cover)),
          Positioned(top: 8, right: 8, child: GestureDetector(onTap: () => setState(() => _image = null), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 20)))),
        ]) else OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.add_photo_alternate), label: const Text('Add Photo'), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48))),
      ]),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() => _image = bytes);
  }

  Future<void> _post() async {
    final user = ref.read(userProvider);
    if (user == null) return;
    setState(() => _isPosting = true);
    try {
      final firebase = ref.read(firebaseServiceProvider);
      List<String> imageUrls = [];
      if (_image != null) {
        final url = await firebase.uploadPostImage('${DateTime.now().millisecondsSinceEpoch}', _image!);
        imageUrls.add(url);
      }
      final post = PostModel(id: '', authorId: user.uid, authorName: user.name, authorPhotoUrl: user.photoUrl, authorRole: user.role, content: _contentController.text.trim(), imageUrls: imageUrls, createdAt: DateTime.now());
      await firebase.createPost(post);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted! 🎉'), backgroundColor: AppColors.success)); Navigator.pop(context); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() { _contentController.dispose(); super.dispose(); }
}
