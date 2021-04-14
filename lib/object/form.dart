class FormSetting {
  String bannerVideoLink, formBanner, formColor, description, name, publicURL;
  int status, bannerStatus;

  FormSetting(
      {this.bannerVideoLink,
      this.formBanner,
      this.formColor,
      this.description,
      this.name,
      this.publicURL,
      this.status,
      this.bannerStatus});

  fromJson(Map<String, dynamic> json) {
    print(json['banner_video_link']);
    return FormSetting(
        bannerVideoLink: json['banner_video_link'],
        formBanner: json['form_banner'],
        formColor: json['form_color'],
        description: json['description'],
        name: json['name'],
        publicURL: json['public_url'],
        status: json['status'] as int,
        bannerStatus: json['banner_status'] as int);
  }
}
