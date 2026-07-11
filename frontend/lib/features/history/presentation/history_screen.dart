import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../scan/data/scan_repository.dart';
import '../../scan/domain/scan_result.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<ScanResult> _scans = [];
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
          _scans = scans;
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
      appBar: AppBar(title: const Text('Scan History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scans.isEmpty
              ? const Center(child: Text('No history found.'))
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    itemCount: _scans.length,
                    itemBuilder: (context, index) {
                      final scan = _scans[index];
                      Color indicatorColor = scan.overallIndicator == 'GREEN' ? Colors.green 
                                           : scan.overallIndicator == 'YELLOW' ? Colors.orange : Colors.red;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: indicatorColor.withOpacity(0.2),
                            child: Text(
                              scan.overallHealthScore.toString(),
                              style: TextStyle(color: indicatorColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(scan.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(scan.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/result', extra: scan),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
