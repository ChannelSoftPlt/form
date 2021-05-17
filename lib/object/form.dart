import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my/utils/HexColor.dart';

class FormSetting {
  String bannerVideoLink,
      formBanner,
      formColor,
      description,
      name,
      publicURL,
      defaultLanguage;
  int status, bannerStatus, productViewPhone;
  CustomColor customColor;

  FormSetting(
      {this.bannerVideoLink,
      this.formBanner,
      this.formColor,
      this.description,
      this.name,
      this.publicURL,
      this.status,
      this.customColor,
      this.bannerStatus,
      this.defaultLanguage,
      this.productViewPhone});

  fromJson(Map<String, dynamic> json) {
    return FormSetting(
        bannerVideoLink: json['banner_video_link'],
        formBanner: json['form_banner'],
        formColor: json['form_color'],
        description: json['description'],
        name: json['name'],
        publicURL: json['public_url'],
        defaultLanguage: json['default_language'],
        customColor: getColor(json['color']),
        status: json['status'] as int,
        bannerStatus: json['banner_status'] as int,
        productViewPhone: json['product_view_phone'] as int);
  }

  static CustomColor getColor(data) {
    try {
      return CustomColor.fromJson(jsonDecode(data));
    } catch ($e) {
      print($e);
      return CustomColor.fromJson('');
    }
  }
}

class CustomColor {
  Color primaryColor, secondColor;

  CustomColor({this.primaryColor, this.secondColor});

  Map toJson() => {
        'primary_color': primaryColor.toHex().toString(),
        'second_color': secondColor.toHex().toString()
      };

  static fromJson(json) {
    return CustomColor(
        primaryColor: HexColor(json != '' ? json['primary_color'] : '#000000'),
        secondColor: HexColor(json != '' ? json['second_color'] : '#666f7b'));
  }
}
