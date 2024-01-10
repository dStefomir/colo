import 'package:cloud_firestore/cloud_firestore.dart';

/// Fire store service
class FireStoreService {
  /// Current user id
  final String userId;

  const FireStoreService({required this.userId});

  /// Unlocks the game mode overlay when starting
  void unlockDifficultySelector() {
    FirebaseFirestore
        .instance
        .collection("users")
        .doc(userId)
        .update({"difficulty_select": true});
    _updateCommonFields();
  }

  /// Unlocks premium
  void unlockPremium() {
    FirebaseFirestore
        .instance
        .collection("users")
        .doc(userId)
        .update(
        {
          "account_type": "premium",
          "premium": true,
          "difficulty_select": true,
          "game_ads": true,
          "rocket_limiter": true
        });
    _updateCommonFields();
  }

  /// Unlocks removal of ads
  void unlockNoAds() {
    FirebaseFirestore
        .instance
        .collection("users")
        .doc(userId)
        .update({"game_ads": true});
    _updateCommonFields();
  }

  /// Unlocks rocket limiter removal
  void unlockRocketLimiterRemoval() {
    FirebaseFirestore
        .instance
        .collection("users")
        .doc(userId)
        .update({"rocket_limiter": true});
    _updateCommonFields();
  }

  /// Updates all common fields in fire store
  void _updateCommonFields() {
    FirebaseFirestore
        .instance
        .collection("users")
        .doc(userId)
        .update({"updated": DateTime.now()});
  }
}