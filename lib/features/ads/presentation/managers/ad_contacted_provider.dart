import 'package:flutter_riverpod/flutter_riverpod.dart';

final adContactedProvider =
    StateProvider.autoDispose.family<bool, String>((ref, adId) => false);
