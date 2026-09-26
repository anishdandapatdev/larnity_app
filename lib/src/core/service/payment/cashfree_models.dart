class CashfreePaymentLinkResponse {
  final String? cfLinkId;
  final String linkId;
  final String linkUrl;
  final String linkStatus;
  final double linkAmount;
  final String linkCurrency;
  final Map<String, dynamic>? customerDetails;
  final String? linkPurpose;
  final String? qrCode;

  CashfreePaymentLinkResponse({
    this.cfLinkId,
    required this.linkId,
    required this.linkUrl,
    required this.linkStatus,
    required this.linkAmount,
    this.linkCurrency = 'INR',
    this.customerDetails,
    this.linkPurpose,
    this.qrCode,
  });

  bool get isPaid => linkStatus.toUpperCase() == 'PAID';
  bool get isActive => linkStatus.toUpperCase() == 'ACTIVE';
  bool get isCancelled => linkStatus.toUpperCase() == 'CANCELLED';
  bool get isExpired => linkStatus.toUpperCase() == 'EXPIRED';

  factory CashfreePaymentLinkResponse.fromMap(Map<String, dynamic> map) {
    return CashfreePaymentLinkResponse(
      cfLinkId: map['cf_link_id']?.toString(),
      linkId: map['link_id'] as String? ?? '',
      linkUrl: map['link_url'] as String? ?? '',
      linkStatus: map['link_status'] as String? ?? 'ACTIVE',
      linkAmount: (map['link_amount'] as num?)?.toDouble() ?? 0.0,
      linkCurrency: map['link_currency'] as String? ?? 'INR',
      customerDetails: map['customer_details'] as Map<String, dynamic>?,
      linkPurpose: map['link_purpose'] as String?,
      qrCode: map['link_qrcode'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cf_link_id': cfLinkId,
      'link_id': linkId,
      'link_url': linkUrl,
      'link_status': linkStatus,
      'link_amount': linkAmount,
      'link_currency': linkCurrency,
      'customer_details': customerDetails,
      'link_purpose': linkPurpose,
      'link_qrcode': qrCode,
    };
  }
}
