import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirpay/shared/widgets/empty_state.dart';
import 'package:nirpay/shared/widgets/error_state.dart';
import 'package:nirpay/shared/widgets/loading_state.dart';

class AppAsyncView<T> extends StatelessWidget {
  const AppAsyncView({
    super.key,
    required this.value,
    required this.data,
    this.empty,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? empty;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (result) {
        if (result is Iterable && result.isEmpty) {
          return empty ?? const EmptyState();
        }
        return data(result);
      },
      loading: () => const LoadingState(),
      error: (error, stackTrace) =>
          ErrorState(message: error.toString(), onRetry: onRetry),
    );
  }
}
