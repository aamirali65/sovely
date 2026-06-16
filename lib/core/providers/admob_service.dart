import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  // ── Set this to true ONLY for development testing ──
  // Use Google test ads (no real impressions counted).
  // In production (release builds), always set to false.
  static bool useTestAds = false;

  // ── Your Real AdMob Unit IDs ──
  static const String _bannerProd       = 'ca-app-pub-8214884614326042/4141502783';
  static const String _interstitialProd = 'ca-app-pub-8214884614326042/2828421115';
  static const String _rewardedProd     = 'ca-app-pub-8214884614326042/5288031099';

  // ── Google Test Ad Unit IDs ──
  static const String _bannerTest       = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialTest = 'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedTest     = 'ca-app-pub-3940256099942544/5224354917';

  static String get bannerAdUnitId       => useTestAds ? _bannerTest       : _bannerProd;
  static String get interstitialAdUnitId => useTestAds ? _interstitialTest : _interstitialProd;
  static String get rewardedAdUnitId     => useTestAds ? _rewardedTest     : _rewardedProd;

  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _loadingInterstitial = false;
  static bool _loadingRewarded = false;
  static int _interstitialRetries = 0;
  static int _rewardedRetries = 0;
  static const int _maxRetries = 5;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();

    if (useTestAds) {
      debugPrint('📢 AdMob: using TEST ads');
    } else {
      debugPrint('📢 AdMob: using PRODUCTION ads');
    }

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
    if (_loadingInterstitial) return;
    _loadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadingInterstitial = false;
          _interstitialRetries = 0;
          debugPrint('📢 Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _loadingInterstitial = false;
          debugPrint('📢 Interstitial failed (${error.message})');

          // Auto-retry with backoff (max 5 times)
          if (_interstitialRetries < _maxRetries) {
            _interstitialRetries++;
            final delay = Duration(seconds: _interstitialRetries * 2);
            debugPrint('📢 Retrying interstitial in ${delay.inSeconds}s (attempt $_interstitialRetries)');
            Future.delayed(delay, _loadInterstitial);
          }
        },
      ),
    );
  }

  static bool get isInterstitialReady => _interstitialAd != null;

  static void showInterstitial({VoidCallback? onDismissed}) {
    final ad = _interstitialAd;
    if (ad == null) {
      debugPrint('📢 Interstitial not ready, loading...');
      _loadInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialRetries = 0;
        _loadInterstitial();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
        debugPrint('📢 Interstitial show failed: ${error.message}');
      },
    );
    ad.show();
  }

  // ── Rewarded ────────────────────────────────────────────
  static void _loadRewarded() {
    if (_loadingRewarded) return;
    _loadingRewarded = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
          _rewardedRetries = 0;
          debugPrint('📢 Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _loadingRewarded = false;
          debugPrint('📢 Rewarded ad failed (${error.message})');

          if (_rewardedRetries < _maxRetries) {
            _rewardedRetries++;
            final delay = Duration(seconds: _rewardedRetries * 2);
            debugPrint('📢 Retrying rewarded in ${delay.inSeconds}s (attempt $_rewardedRetries)');
            Future.delayed(delay, _loadRewarded);
          }
        },
      ),
    );
  }

  static bool get isRewardedReady => _rewardedAd != null;

  static void showRewarded({
    required void Function(AdWithoutView, RewardItem) onRewarded,
    VoidCallback? onFailed,
  }) {
    final ad = _rewardedAd;
    if (ad == null) {
      debugPrint('📢 Rewarded ad not ready');
      onFailed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedRetries = 0;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
        debugPrint('📢 Rewarded show failed: ${error.message}');
        onFailed?.call();
      },
    );
    ad.show(onUserEarnedReward: onRewarded);
  }
}
