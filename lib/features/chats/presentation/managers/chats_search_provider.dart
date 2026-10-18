import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatsSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

