import 'package:flutter/material.dart';
import 'package:ocr_app/models/ocr_result.dart';

class OcrResultEditor extends StatefulWidget {
  final OcrResult initialResult;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const OcrResultEditor({
    super.key,
    required this.initialResult,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<OcrResultEditor> createState() => _OcrResultEditorState();
}

class _OcrResultEditorState extends State<OcrResultEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialResult.text);
  }

  @override
  void didUpdateWidget(OcrResultEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialResult.text != widget.initialResult.text) {
      _controller.text = widget.initialResult.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_document,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '编辑识别结果',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (widget.initialResult.confidence > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(widget.initialResult.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getConfidenceColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: '识别结果将显示在这里...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.onClear != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('清空'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    final confidence = widget.initialResult.confidence;
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.7) return Colors.orange;
    return Colors.red;
  }
}
