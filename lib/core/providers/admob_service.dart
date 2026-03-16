// lib/core/services/admob_service.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static const String bannerAdUnitId       = 'ca-app-pub-8214884614326042/4141502783';
  static const String interstitialAdUnitId = 'ca-app-pub-8214884614326042/2828421115';
  static const String rewardedAdUnitId     = 'ca-app-pub-8214884614326042/5288031099';

  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  /// Call once in main.dart
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  // ── Banner ──────────────────────────────────────────────
  static BannerAd createBanner({
    required void Function(Ad, LoadAdError) onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdFailedToLoad: onFailed),
    )..load();
  }

  // ── Interstitial ────────────────────────────────────────
  static void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  static void showInterstitial({VoidCallback? onDismissed}) {
    if (_interstitialAd == null) return;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        onDismissed?.call();
      },
    );
    _interstitialAd!.show();
  }

  // ── Rewarded ────────────────────────────────────────────
  static void _loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  static void showRewarded({
    required void Function(AdWithoutView, RewardItem) onRewarded,
  }) {
    if (_rewardedAd == null) return;
    _rewardedAd!.show(onUserEarnedReward: onRewarded);
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
      },
    );
  }
}