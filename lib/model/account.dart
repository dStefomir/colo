/// Account model
class Account {
  /// User account type
  String? accountType;
  /// Last update
  DateTime? updated;

  Account();

  Map<String, dynamic> toJson() => {'account_type': accountType, "updated": updated};

  Account.fromSnapshot(snapshot) :
      accountType = snapshot.data()?['account_type'],
      updated = snapshot.data()?['updated']?.toDate();
}