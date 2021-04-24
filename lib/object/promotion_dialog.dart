class PromotionDialog {
  String promoTitle,
      promoMainTitle,
      buttonTittle,
      smallTitle,
      smallSubtitle,
      overlayColor,
      textColor,
      promoImage;

  double overlayOpacity;
  bool promoActive;

  PromotionDialog(
      {this.promoTitle,
      this.promoMainTitle,
      this.buttonTittle,
      this.smallTitle,
      this.smallSubtitle,
      this.overlayColor,
      this.textColor,
      this.overlayOpacity,
      this.promoImage,
      this.promoActive});

  static presetData() {
    return PromotionDialog(
        promoActive: false,
        promoTitle: 'Christmas & New Year Promo',
        promoMainTitle: '\$20 Off',
        buttonTittle: 'Shop Now',
        smallTitle: 'T&C Apply',
        smallSubtitle:
            '\$10 of this voucher can redeem on any of our services. Another \$10 is applicable with minimum spend of \$100.',
        overlayColor: '#201111',
        overlayOpacity: 50,
        textColor: '#FFFEFE',
        promoImage: '');
  }

  factory PromotionDialog.fromJson(Map<String, dynamic> json) {
    return PromotionDialog(
      promoActive: json['promo_active'] as bool,
      promoTitle: json['promo_title'] as String,
      promoMainTitle: json['promo_main_title'] as String,
      buttonTittle: json['button_title'] as String,
      smallTitle: json['small_title'] as String,
      smallSubtitle: json['small_subtitle'] as String,
      overlayColor: json['overlay_color'] as String,
      textColor: json['text_color'] as String,
      overlayOpacity: checkDouble(json['overlay_opacity']),
      promoImage: json['promo_image'] as String,
    );
  }

  static double checkDouble(value) {
    try {
      return value is double ? value : double.parse(value);
    } catch ($e) {
      return 0.00;
    }
  }

  static List<PromotionDialog> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => PromotionDialog.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() => {
        'promo_active': promoActive,
        'promo_title': promoTitle,
        'promo_main_title': promoMainTitle,
        'button_title': buttonTittle,
        'small_title': smallTitle,
        'small_subtitle': smallSubtitle,
        'overlay_color': overlayColor,
        'text_color': textColor,
        'overlay_opacity': overlayOpacity,
        'promo_image': promoImage
      };
}
