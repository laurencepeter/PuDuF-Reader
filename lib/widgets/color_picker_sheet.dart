import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../config/app_colors.dart';
import 'futuristic_button.dart';

class ColorPickerSheet extends StatefulWidget {
  final Color initialColor;
  final String title;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerSheet({
    super.key,
    required this.initialColor,
    required this.title,
    required this.onColorChanged,
  });

  static Future<Color?> show(
    BuildContext context, {
    required Color initialColor,
    required String title,
  }) async {
    Color? result;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ColorPickerSheet(
        initialColor: initialColor,
        title: title,
        onColorChanged: (c) => result = c,
      ),
    );
    return result;
  }

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: AppColors.cardBorder),
          left: BorderSide(color: AppColors.cardBorder),
          right: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          ColorPicker(
            pickerColor: _color,
            onColorChanged: (c) {
              setState(() => _color = c);
              widget.onColorChanged(c);
            },
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.46,
            hexInputBar: true,
            pickerAreaBorderRadius:
                const BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(height: 20),
          FuturisticButton(
            label: 'APPLY',
            icon: Icons.check_rounded,
            width: double.infinity,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
