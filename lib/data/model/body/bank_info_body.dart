class BankInfoBody {
  String? bankName;
  String? branch;
  String? holderName;
  String? accountNo;

  BankInfoBody({
    this.bankName,
    this.branch,
    this.holderName,
    this.accountNo,
  });

  factory BankInfoBody.fromJson(Map<String, dynamic> json) {
    return BankInfoBody(
      bankName: json['bank_name'] as String?,
      branch: json['branch'] as String?,
      holderName: json['holder_name'] as String?,
      accountNo: json['account_no'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'branch': branch,
      'holder_name': holderName,
      'account_no': accountNo,
    };
  }
}
