class Address {
  final String address_id;
  final String address_name;
  final String address_zone_id;
  final String address_zone_name;

  Address({
    required this.address_id,
    required this.address_name,
    required this.address_zone_id,
    required this.address_zone_name,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address_id: json['address_id'],
      address_name: json['address_name'],
      address_zone_id: json['address_zone_id'],
      address_zone_name: json['address_zone_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_id': address_id,
      'address_name': address_name,
      'address_zone_id': address_zone_id,
      'address_zone_name': address_zone_name,
    };
  }
}

class ListAddressesResponse {
  final List<Address> addresses;
  final List<dynamic> recent_addresses;

  ListAddressesResponse({
    required this.addresses,
    required this.recent_addresses,
  });

  factory ListAddressesResponse.fromJson(Map<String, dynamic> json) {
    return ListAddressesResponse(
      addresses: (json['addresses'] as List)
          .map((address) => Address.fromJson(address))
          .toList(),
      recent_addresses: json['recent_addresses'] ?? [],
    );
  }
}