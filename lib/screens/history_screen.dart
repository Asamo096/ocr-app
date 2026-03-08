import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ocr_record.dart';
import '../providers/ocr_provider.dart';
import '../utils/helpers.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: '清空历史',
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
      body: Consumer<OcrProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无历史记录'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                final record = provider.history[index];
                return _RecordListTile(
                  record: record,
                  onDelete: () => _deleteRecord(context, provider, record),
                  onTap: () => _showRecordDetail(context, record),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showClearHistoryDialog(BuildContext context) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: '清空历史',
      content: '确定要清空所有历史记录吗？此操作不可恢复。',
      confirmText: '清空',
    );

    if (confirmed && context.mounted) {
      final provider = context.read<OcrProvider>();
      for (final record in provider.history) {
        await provider.deleteRecord(record.id!);
      }
    }
  }

  Future<void> _deleteRecord(
    BuildContext context,
    OcrProvider provider,
    OcrRecord record,
  ) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: '删除记录',
      content: '确定要删除这条记录吗？',
    );

    if (confirmed) {
      await provider.deleteRecord(record.id!);
    }
  }

  void _showRecordDetail(BuildContext context, OcrRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _RecordDetailSheet(
          record: record,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _RecordListTile extends StatelessWidget {
  final OcrRecord record;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _RecordListTile({
    required this.record,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('record_${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Image.file(
              File(record.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        title: Text(
          Helpers.truncateText(record.displayText, 50),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          Helpers.formatDateShort(record.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => Helpers.copyToClipboard(context, record.displayText),
        ),
      ),
    );
  }
}

class _RecordDetailSheet extends StatelessWidget {
  final OcrRecord record;
  final ScrollController scrollController;

  const _RecordDetailSheet({
    required this.record,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '记录详情',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Helpers.copyToClipboard(context, record.displayText);
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(record.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '识别结果',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(record.displayText),
                ),
                const SizedBox(height: 16),
                Text(
                  '创建时间: ${Helpers.formatDate(record.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
