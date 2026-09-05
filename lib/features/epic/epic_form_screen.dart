import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/epic.dart';
import 'pixel_flag.dart';

class EpicFormScreen extends StatefulWidget {
  final Epic? epic;
  final String? defaultListId;
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
    _color = widget.epic?.color ?? const Color(0xFFC43C2E);
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
      await provider.updateEpic(widget.epic!.copyWith(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        colorValue: _color.value,
        emoji: emoji.isEmpty ? null : emoji,
        clearEmoji: emoji.isEmpty,
      ));
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
          title: Text('Цвет флага', style: AppTheme.pixelTitle(color: context.pxFg, size: 10)),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _color,
              onColorChanged: (c) => temp = c,
              availableColors: const [
                Color(0xFFC43C2E), Color(0xFFB44A62), Color(0xFFC45C26), Color(0xFFB8922A),
                Color(0xFF3D8B5C), Color(0xFF2A7A6E), Color(0xFF3A6EA5), Color(0xFF5C6570),
                Color(0xFFE53935), Color(0xFF8E24AA), Color(0xFF1E88E5), Color(0xFF00897B),
                Color(0xFFFB8C00), Color(0xFF6D4C41), Color(0xFF212121), Color(0xFF757575),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(onPressed: () { setState(() => _color = temp); Navigator.pop(ctx); }, child: const Text('Выбрать')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentListName = widget.defaultListId != null
        ? context.read<AppProvider>().lists.where((l) => l.id == widget.defaultListId).map((l) => l.name).firstOrNull
        : null;
    final emoji = _emojiCtrl.text.trim();

    return Scaffold(
      backgroundColor: context.pxBg,
      appBar: AppBar(
        title: Text(isEditing ? 'ПРАВИТЬ ЭПИК' : 'НОВЫЙ ЭПИК', style: AppTheme.pixelTitle(color: context.pxFg, size: 10)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: context.pxLine, width: 2),
              boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(2, 2))],
            ),
            child: Material(
              color: context.pxPanel,
              child: InkWell(
                onTap: _save,
                child: Container(width: 32, height: 32, alignment: Alignment.center, child: const Icon(Icons.check_rounded, size: 16)),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      bottom: MediaQuery.of(context).padding.bottom + 100, // + отступ для Android навигации
    ),
          children: [
            Center(
              child: GestureDetector(
                onTap: emoji.isEmpty ? _pickColor : null,
                child: Column(
                  children: [
                    if (emoji.isNotEmpty) Text(emoji, style: const TextStyle(fontSize: 48)) else PixelFlag(color: _color, size: 56),
                    const SizedBox(height: 8),
                    Text(emoji.isNotEmpty ? 'Эмодзи вместо флага' : 'Нажми на флаг, чтобы сменить цвет', style: AppTheme.body(size: 12, color: context.pxSubtle), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emojiCtrl,
              decoration: const InputDecoration(labelText: 'Эмодзи (необязательно)', prefixIcon: Icon(Icons.emoji_emotions_outlined, size: 20)),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (emoji.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: context.pxLine, width: 2), boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(2, 2))]),
                  child: Material(
                    color: context.pxPanel,
                    child: InkWell(
                      onTap: _pickColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.palette_outlined, size: 16), const SizedBox(width: 8), Text('Цвет флага', style: AppTheme.body(size: 12))]),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Название эпика', prefixIcon: Icon(Icons.title, size: 20)),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Описание (необязательно)', prefixIcon: Icon(Icons.notes, size: 20), alignLabelWithHint: true),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            if (!isEditing && widget.defaultListId != null) ...[
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _addToCurrentList,
                onChanged: (v) => setState(() => _addToCurrentList = v ?? true),
                activeColor: AppTheme.accent,
                title: Text(currentListName != null ? 'Добавить в «$currentListName»' : 'Добавить в текущий список', style: AppTheme.body(size: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: context.isDark ? Colors.black : const Color(0x33000000), offset: const Offset(2, 2), blurRadius: 0)]),
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: Text(isEditing ? 'СОХРАНИТЬ' : 'СОЗДАТЬ', style: AppTheme.pixelSmall(color: const Color(0xFFE8B896))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}