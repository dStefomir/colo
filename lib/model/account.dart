/// Account model
class Account {
  /// User account type
  String? _accountType;
  /// Is the user able to select game difficulty
  bool? _difficultySelect;
  /// Is the user an premium one
  bool? premium;
  /// Are game ads removed
  bool? _noAds;
  /// Is there a rocket limiter
  bool? _rocketLimiter;
  /// Last update
  DateTime? updated;

  Account();

  Map<String, dynamic> toJson() => {
    'account_type': _accountType ?? 'free',
    'updated': updated ?? DateTime.now(),
    'premium': premium ?? false,
    'difficulty_select': _difficultySelect ?? false,
    'game_ads': _noAds ?? false,
    'rocket_limiter': _rocketLimiter ?? false,
  };

  Account.fromSnapshot(snapshot) :
      _accountType = snapshot?.data()?['account_type'],
      updated = snapshot?.data()?['updated']?.toDate(),
      _difficultySelect = snapshot?.data()?['difficulty_select'] ?? false,
      premium = snapshot?.data()?['premium'] ?? false,
      _noAds = snapshot?.data()?['game_ads'] ?? false,
      _rocketLimiter = snapshot?.data()?['rocket_limiter'] ?? false;

  /// Getter for the account type
  String get accountType {
    if (premium != null && premium == true) {
      return 'premium';
    }

    return 'free';
  }

  /// Getter for the difficulty select
  bool get difficultySelect {
    if (premium != null && premium == true) {
      return true;
    }

    return _difficultySelect ?? false;
  }

  /// Getter for the difficulty select
  bool get noAds {
    if (premium != null && premium == true) {
      return true;
    }

    return _noAds ?? false;
  }

  /// Getter for the difficulty select
  bool get rocketLimiter {
    if (premium != null && premium == true) {
      return true;
    }

    return _rocketLimiter ?? false;
  }
}