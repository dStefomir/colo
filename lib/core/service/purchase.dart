import 'package:colo/core/service/firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Service for the in app purchases
class InAppPurchaseService {

  final FireStoreService fireStoreService;

  const InAppPurchaseService({required this.fireStoreService});

  /// Listen for purchase that is pending to be completed
  void listenToPurchaseUpdated(List<PurchaseDetails> purchasesDetails) {
    purchasesDetails.forEach((purchase) async {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails: purchase);
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
        if (kDebugMode) {
          print("Purchase completed");
        }
      }
    });
  }

  /// Handles the bought game item
  void _handleSuccessfulPurchase({required PurchaseDetails purchaseDetails}) {
    switch (purchaseDetails.productID) {
      case 'difficulty_select':
        fireStoreService.unlockDifficultySelector();
        break;
      case 'premium':
        fireStoreService.unlockPremium();
        break;
      case 'game_ads':
        fireStoreService.unlockNoAds();
        break;
      case 'rocket_limiter':
        fireStoreService.unlockRocketLimiterRemoval();
        break;
    }
  }
}