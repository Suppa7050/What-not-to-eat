import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/scan_repository.dart';
import '../../profile/data/profile_repository.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final String initialType;
  const ScanScreen({super.key, this.initialType = 'ingredient'});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  File? _imageFile;
  late String _scanType;
  bool _isScanning = false;
  String? _errorMessage;
  final _concernController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scanType = widget.initialType;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileDetails();
    });
  }

  Future<void> _checkProfileDetails() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      // If user hasn't added all of the key details, show the popup
      if (profile.age == null || profile.height == null || profile.weight == null) {
        if (mounted) _showProfileDetailsPopup();
      }
    } catch (e) {
      debugPrint('Failed to check profile details: $e');
    }
  }

  void _showProfileDetailsPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personalize Your Experience'),
        content: const Text('Please add your details (like age, weight, or health conditions) so we can accurately personalize the dietary analysis for you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/profile-setup');
            },
            child: const Text('Add Details'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _errorMessage = null);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // compress slightly
        maxWidth: 1500,
      );
      if (pickedFile != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Ingredient List',
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Ingredient List',
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _imageFile = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    setState(() => _isScanning = true);

    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      final concern = _concernController.text.trim();

      final result = await ref.read(scanRepositoryProvider).scanImage(
        imageFile: _imageFile!, 
        profile: profile,
        concern: concern.isNotEmpty ? concern : null,
        scanType: _scanType,
      );
      if (mounted) {
        context.pushReplacement('/result', extra: result);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        setState(() {
          _isScanning = false;
          _errorMessage = errorMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ingredients')),
      body: _isScanning 
        ? _buildLoadingState() 
        : _errorMessage != null
          ? _buildErrorState()
          : _buildSetupState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analyzing ingredients...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Our AI is carefully reviewing the nutritional data.'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _errorMessage = null);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupState() {
    return Column(
      children: [
        Expanded(
          child: _imageFile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_imageFile == null) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment<String>(
                                value: 'ingredient',
                                label: Text('Ingredient List'),
                                icon: Icon(Icons.document_scanner),
                              ),
                              ButtonSegment<String>(
                                value: 'food',
                                label: Text('Food Image'),
                                icon: Icon(Icons.fastfood),
                              ),
                            ],
                            selected: <String>{_scanType},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _scanType = newSelection.first;
                              });
                            },
                          ),
                        ),
                      ],
                      Icon(
                        _scanType == 'ingredient' ? Icons.document_scanner : Icons.fastfood, 
                        size: 80, 
                        color: Colors.green[400]
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _scanType == 'ingredient' ? 'Scan the list of ingredients' : 'Scan the food image', 
                        style: TextStyle(color: Colors.green[800], fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                )
              : Image.file(_imageFile!, fit: BoxFit.contain),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageFile != null) ...[
                TextField(
                  controller: _concernController,
                  decoration: InputDecoration(
                    labelText: 'Any specific concerns?',
                    hintText: 'e.g., My child has a cold, can they eat this?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _imageFile == null ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text('Analyze ${_scanType == 'ingredient' ? 'Ingredients' : 'Food'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
