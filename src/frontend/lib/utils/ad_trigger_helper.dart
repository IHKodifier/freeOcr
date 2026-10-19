import 'ad_trigger_stub.dart'
    if (dart.library.js) 'ad_trigger_web.dart' as impl;

/// Helper to trigger Monetag high-yield ad formats upon explicit user demand.
class AdTriggerHelper {
  static void triggerMonetagAd({String? directLinkUrl}) {
    impl.triggerMonetagAd(directLinkUrl: directLinkUrl);
  }
}
