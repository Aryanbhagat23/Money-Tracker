import 'dart:convert';

/// A trusted person the user can check with before paying anyone.
class FamilyContact {
  const FamilyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relation = '',
  });

  final String id;
  final String name;
  final String phone;
  final String relation;

  /// Phone number with spaces, dashes and brackets removed, for tel:/sms: links.
  String get dialable => phone.replaceAll(RegExp(r'[^0-9+]'), '');

  bool get hasValidPhone => RegExp(r'^\+?[0-9]{7,15}$').hasMatch(dialable);

  FamilyContact copyWith({String? name, String? phone, String? relation}) =>
      FamilyContact(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        relation: relation ?? this.relation,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relation': relation,
  };

  factory FamilyContact.fromJson(Map<String, dynamic> json) => FamilyContact(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    relation: (json['relation'] as String?) ?? '',
  );

  static String encodeList(List<FamilyContact> contacts) =>
      jsonEncode(contacts.map((c) => c.toJson()).toList());

  static List<FamilyContact> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FamilyContact.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  @override
  bool operator ==(Object other) =>
      other is FamilyContact &&
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.relation == relation;

  @override
  int get hashCode => Object.hash(id, name, phone, relation);
}
