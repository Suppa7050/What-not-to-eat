import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/profile_repository.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  bool _hasDiabetes = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (mounted) {
        setState(() {
          _isLoggedIn = token != null && token.isNotEmpty;
        });
      }

      final profile = await ref.read(profileRepositoryProvider).getProfile();
      if (profile.username != null) _usernameController.text = profile.username!;
      if (profile.age != null) _ageController.text = profile.age.toString();
      if (profile.height != null) _heightController.text = profile.height.toString();
      if (profile.weight != null) _weightController.text = profile.weight.toString();
      if (profile.additionalNotes != null) _notesController.text = profile.additionalNotes!;
      _hasDiabetes = profile.hasDiabetes;
    } catch (e) {
      debugPrint('No existing profile or error: $e');
    }
  }

  Future<void> _skipSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_setup_skipped', true);
    if (mounted) context.go('/');
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();

    setState(() => _isLoading = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
        username: username,
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        hasDiabetes: _hasDiabetes,
        additionalNotes: _notesController.text.trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profile_setup_skipped', true);
      if (mounted) context.go('/'); // Go to home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Personalizing your experience will help us give better dietary advice.'),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age (years)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Do you have diabetes?'),
                value: _hasDiabetes,
                onChanged: (val) => setState(() => _hasDiabetes = val),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Anything else that matters',
                  hintText: 'e.g. I am on a weight loss process, lactose intolerant...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save & Continue', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _skipSetup,
                child: const Text('Continue without information', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
              if (!_isLoggedIn) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text('Login to sync data'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.push('/login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
