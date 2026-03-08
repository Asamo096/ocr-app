import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ocr_result.dart';
import '../utils/helpers.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final OcrResult ocrResult;
  final String editedText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSave;
  final VoidCallback onRetake;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.ocrResult,
    required this.editedText,
    required this.onTextChanged,
    required this.onSave,
    required this.onRetake,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.editedText);
  }

  @override
  void didUpdateWidget(ResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只有当文本真正改变时才更新控制器
    if (oldWidget.editedText != widget.editedText && 
        _controller.text != widget.editedText) {
      // 保存当前光标位置
      final selection = _controller.selection;
      _controller.text = widget.editedText;
      // 恢复光标位置
      _controller.selection = selection;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _ImagePreview(imagePath: widget.imagePath),
        ),
        const Divider(height: 1),
        Expanded(
          flex: 3,
          child: _ResultEditor(
            ocrResult: widget.ocrResult,
            controller: _controller,
            onTextChanged: widget.onTextChanged,
          ),
        ),
        _ActionButtons(
          onSave: widget.onSave,
          onRetake: widget.onRetake,
          onCopy: () => Helpers.copyToClipboard(context, _controller.text),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String imagePath;

  const _ImagePreview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.white54),
                  SizedBox(height: 8),
                  Text(
                    '无法加载图片',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResultEditor extends StatelessWidget {
  final OcrResult ocrResult;
  final TextEditingController controller;
  final ValueChanged<String> onTextChanged;

  const _ResultEditor({
    required this.ocrResult,
    required this.controller,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '识别结果',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (ocrResult.confidence > 0)
                Text(
                  '置信度: ${(ocrResult.confidence * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                filled: true,
                hintText: '识别结果将显示在这里...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onTextChanged,
            ),
          ),
          if (ocrResult.processingTime.inMilliseconds > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '识别耗时: ${ocrResult.processingTime.inMilliseconds}ms',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onRetake;
  final VoidCallback onCopy;

  const _ActionButtons({
    required this.onSave,
    required this.onRetake,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh),
                label: const Text('重新拍摄'),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
              tooltip: '复制',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save),
                label: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
