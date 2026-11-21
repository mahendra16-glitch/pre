class GetDeliveryChargesResponse {
  String? distance;
  double? shippingCharge;
  DistanceDetails? distanceDetails;

  GetDeliveryChargesResponse({
    this.distance,
    this.shippingCharge,
    this.distanceDetails,
  });

  GetDeliveryChargesResponse.fromJson(Map<String, dynamic> json) {
    distance = json['distance'] as String?;
    shippingCharge = (json['shipping_charge'] != null)
        ? double.tryParse(json['shipping_charge'].toString())
        : null;
    distanceDetails = json['distance_details'] != null
        ? DistanceDetails.fromJson(
            json['distance_details'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['distance'] = distance;
    data['shipping_charge'] = shippingCharge;
    if (distanceDetails != null) {
      data['distance_details'] = distanceDetails!.toJson();
    }
    return data;
  }
}

class DistanceDetails {
  List<String>? destinationAddresses;
  List<String>? originAddresses;
  List<Rows>? rows;
  String? status;

  DistanceDetails({
    this.destinationAddresses,
    this.originAddresses,
    this.rows,
    this.status,
  });

  DistanceDetails.fromJson(Map<String, dynamic> json) {
    destinationAddresses = (json['destination_addresses'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    originAddresses = (json['origin_addresses'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    if (json['rows'] != null) {
      rows = (json['rows'] as List<dynamic>)
          .map((v) => Rows.fromJson(v as Map<String, dynamic>))
          .toList();
    }
    status = json['status'] as String?;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['destination_addresses'] = destinationAddresses;
    data['origin_addresses'] = originAddresses;
    if (rows != null) {
      data['rows'] = rows!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Rows {
  List<Elements>? elements;

  Rows({this.elements});

  Rows.fromJson(Map<String, dynamic> json) {
    if (json['elements'] != null) {
      elements = (json['elements'] as List<dynamic>)
          .map((v) => Elements.fromJson(v as Map<String, dynamic>))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (elements != null) {
      data['elements'] = elements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Elements {
  Distance? distance;
  Distance? duration;
  String? status;

  Elements({this.distance, this.duration, this.status});

  Elements.fromJson(Map<String, dynamic> json) {
    distance = json['distance'] != null
        ? Distance.fromJson(json['distance'] as Map<String, dynamic>)
        : null;
    duration = json['duration'] != null
        ? Distance.fromJson(json['duration'] as Map<String, dynamic>)
        : null;
    status = json['status'] as String?;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (distance != null) {
      data['distance'] = distance!.toJson();
    }
    if (duration != null) {
      data['duration'] = duration!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class Distance {
  String? text;
  int? value;

  Distance({this.text, this.value});

  Distance.fromJson(Map<String, dynamic> json) {
    text = json['text'] as String?;
    value = json['value'] as int?;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['text'] = text;
    data['value'] = value;
    return data;
  }
}
