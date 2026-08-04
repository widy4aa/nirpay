import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PinInputWidget extends StatelessWidget {
  PinInputWidget({
    super.key,
    required this.pinNotifier,
    required this.onNumberTap,
    required this.onDeleteTap,
  });

  final ValueNotifier<String> pinNotifier;
  final void Function(String number) onNumberTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<String>(
          valueListenable: pinNotifier,
          builder: (context, pin, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < pin.length
                        ? context.colors.primary
                        : context.colors.border,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 48),
        _buildNumberPad(context),
      ],
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var j = 1; j <= 3; j++)
                  _buildNumberButton((i * 3 + j).toString(), context),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 64, height: 64),
              _buildNumberButton('0', context),
              _buildDeleteButton(context),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number, BuildContext context) {
    return InkWell(
      onTap: () => onNumberTap(number),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return InkWell(
      onTap: onDeleteTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          size: 28,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}
