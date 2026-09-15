import 'package:flutter_riverpod/flutter_riverpod.dart';

final exploreGroupExpandedProvider = StateProvider<bool>((ref) => false);

// Helper provider for toggle function
final exploreGroupToggleProvider = Provider<void>((ref) {
  ref.read(exploreGroupExpandedProvider.notifier).update((state) => !state);
});
