import 'package:flutter/material.dart';
import '../models/group_order.dart';

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus current;

  const OrderStatusStepper({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final steps = OrderStatus.values;
    final currentIndex = current.stepIndex;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone
                  ? current.color
                  : const Color(0xFFE2E8F0),
            ),
          );
        } else {
          final stepIndex = i ~/ 2;
          final step = steps[stepIndex];
          final isDone = stepIndex < currentIndex;
          final isActive = stepIndex == currentIndex;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isActive ? 10 : 8,
                height: isActive ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isActive
                      ? current.color
                      : const Color(0xFFE2E8F0),
                  border: isActive
                      ? Border.all(
                          color: current.color.withValues(alpha: 0.3),
                          width: 3,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isActive
                      ? current.color
                      : isDone
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFFCBD5E1),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
