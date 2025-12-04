class SettingsModel {
  final String address;
  final String phone;
  final String email;
  final String website;

  SettingsModel({
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
    };
  }
}

class SettingsResponse {
  final bool success;
  final SettingsModel? data;
  final String? message;

  SettingsResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? SettingsModel.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}
