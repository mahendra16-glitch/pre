class Attr {
  final int? id;
  final String? name;

  Attr({this.id, this.name});

  factory Attr.fromJson(Map<String, dynamic> json) {
    return Attr(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
