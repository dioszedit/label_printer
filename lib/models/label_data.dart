/// Címke adatmodell.
///
/// A nyomtatandó címke három sorát tárolja: név, város, utca és házszám.
class LabelData {
  final String name;
  final String city;
  final String street;

  const LabelData({
    required this.name,
    required this.city,
    required this.street,
  });

  /// Igaz, ha minden mező ki van töltve (nem üres).
  bool get isValid =>
      name.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      street.trim().isNotEmpty;

  LabelData copyWith({
    String? name,
    String? city,
    String? street,
  }) {
    return LabelData(
      name: name ?? this.name,
      city: city ?? this.city,
      street: street ?? this.street,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          city == other.city &&
          street == other.street;

  @override
  int get hashCode => Object.hash(name, city, street);

  @override
  String toString() => 'LabelData(name: $name, city: $city, street: $street)';
}
