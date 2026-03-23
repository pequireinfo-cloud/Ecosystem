import 'package:flutter_riverpod/flutter_riverpod.dart';

enum KycState { unverified, pending, verified }

class KycNotifier extends Notifier<KycState> {
  @override
  KycState build() => KycState.unverified;

  void setPending() => state = KycState.pending;
  void setVerified() => state = KycState.verified;
  void reset() => state = KycState.unverified;
  void updateState(KycState newState) => state = newState;
}

final kycProvider = NotifierProvider<KycNotifier, KycState>(() => KycNotifier());
