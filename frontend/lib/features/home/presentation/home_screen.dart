import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../scan/data/scan_repository.dart';
import '../../scan/domain/scan_result.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ScanResult> _recentScans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final scans = await ref.read(scanRepositoryProvider).getHistory();
      if (mounted) {
        setState(() {
          _recentScans = scans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What Not To Eat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile-setup'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');
              if (mounted) context.go('/login');
            },
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                _buildScanAction(context),
                const SizedBox(height: 24),
                Text('Recent Scans', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (_recentScans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No scans yet. Scan a product to get started!', textAlign: TextAlign.center),
                  )
                else
                  ..._recentScans.take(5).map((scan) => _buildRecentScanCard(scan)),
                  
                if (_recentScans.length > 5)
                  TextButton(
                    onPressed: () => context.push('/history'), 
                    child: const Text('View All History')
                  )
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Product'),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello there!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Ready to discover what\'s really in your food? Scan an ingredient list to get started.'),
          ],
        ),
      ),
    );
  }

  Widget _buildScanAction(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/scan'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(Icons.document_scanner, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Tap to Scan Ingredients', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScanCard(ScanResult scan) {
    Color indicatorColor = scan.overallIndicator == 'GREEN' ? Colors.green 
                         : scan.overallIndicator == 'YELLOW' ? Colors.orange : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: indicatorColor.withOpacity(0.2),
          child: Text(scan.overallHealthScore.toString(), style: TextStyle(color: indicatorColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(scan.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(scan.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Push result screen with data
          context.push('/result', extra: scan);
        },
      ),
    );
  }
}
