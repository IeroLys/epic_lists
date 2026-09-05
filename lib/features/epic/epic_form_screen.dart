import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/epic.dart';
import 'pixel_flag.dart';

class EpicFormScreen extends StatefulWidget {
  final Epic? epic; // null = create
  final String? defaultListId; // if creating, optionally add to this list

  const EpicFormScreen({super.key, this.epic, this.defaultListId});

  @override
  State<EpicFormScreen> createState() => _EpicFormScreenState();
}

class _EpicFormScreenState extends State<EpicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _emojiCtrl;
  late Color _color;
  late bool _addToCurrentList;

  bool get isEditing => widget.epic != null;



  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.epic?.title ?? '');
    _descCtrl = TextEditingController(text: widget.epic?.description ?? '');
    _emojiCtrl = TextEditingController(text: widget.epic?.emoji ?? '');
    _color = widget.epic?.color ?? const Color(0xFFE53935);
    _addToCurrentList = widget.defaultListId != null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final emoji = _emojiCtrl.text.trim();

    if (isEditing) {
      final updated = widget.epic!.copyWith(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        colorValue: _color.value,
        emoji: emoji.isEmpty ? null : emoji,
        clearEmoji: emoji.isEmpty,
      );
      await provider.updateEpic(updated);
    } else {
      await provider.createEpic(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        color: _color,
        emoji: emoji.isEmpty ? null : emoji,
        addToListId: _addToCurrentList ? widget.defaultListId : null,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (ctx) {
        Color temp = _color;
        return AlertDialog(
          title: const Text('Цвет флага'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _color,
              onColorChanged: (c) => temp = c,
              availableColors: const [
                Color(0xFFE53935),
                Color(0xFFD81B60),
                Color(0xFF8E24AA),
                Color(0xFF5E35B1),
                Color(0xFF3949AB),
                Color(0xFF1E88E5),
                Color(0xFF039BE5),
                Color(0xFF00ACC1),
                Color(0xFF00897B),
                Color(0xFF43A047),
                Color(0xFF7CB342),
                Color(0xFFC0CA33),
                Color(0xFFFDD835),
                Color(0xFFFFB300),
                Color(0xFFFB8C00),
                Color(0xFFF4511E),
                Color(0xFF6D4C41),
                Color(0xFF546E7A),
                Color(0xFF212121),
                Color(0xFF757575),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _color = temp);
                Navigator.pop(ctx);
              },
              child: const Text('Выбрать'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentListName = widget.defaultListId != null
        ? context.read<AppProvider>().lists
            .where((l) => l.id == widget.defaultListId)
            .map((l) => l.name)
            .firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать эпик' : 'Новый эпик'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Preview
            Center(
              child: GestureDetector(
                onTap: _pickColor,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_emojiCtrl.text.trim().isNotEmpty)
                          Text(_emojiCtrl.text.trim(), style: const TextStyle(fontSize: 48))
                        else
                          PixelFlag(color: _color, size: 56),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Нажми на флаг, чтобы сменить цвет',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Emoji quick picks
            Text(
              'Эмодзи (необязательно)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emojiCtrl,
              decoration: const InputDecoration(
                labelText: 'Или введи свой эмодзи',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emoji_emotions_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Название эпика',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Описание (необязательно)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),

            if (!isEditing && widget.defaultListId != null) ...[
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _addToCurrentList,
                onChanged: (v) => setState(() => _addToCurrentList = v ?? true),
                title: Text(
                  currentListName != null
                      ? 'Добавить в «$currentListName»'
                      : 'Добавить в текущий список',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _save,
              icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(isEditing ? 'Сохранить изменения' : 'Создать эпик'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
