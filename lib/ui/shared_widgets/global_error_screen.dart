import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

Future<LottieComposition?> _lottieCustomDecoder(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      final matches = files
          .where((f) =>
              f.name.startsWith('animations/') && f.name.endsWith('.json'))
          .toList();
      return matches.isNotEmpty ? matches.first : files.first;
    },
  );
}

class GlobalErrorScreen extends StatelessWidget {
  const GlobalErrorScreen({
    super.key,
    required this.details,
  });

  final FlutterErrorDetails details;

  static const String _lottiePath =
      'assets/social_media/error_404_outdoor.lottie';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  _lottiePath,
                  decoder: _lottieCustomDecoder,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
                const Gap(24),
                Text(
                  'Something went wrong'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                Text(
                  'We caught an error and recorded it. Try again later and we will fix the issue as soon as possible.'
                      .tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode) ...[
                  const Gap(24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      details.exceptionAsString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade800,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
