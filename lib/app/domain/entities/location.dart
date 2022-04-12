class Location {
  final String cep;
  final String place;
  final String complement;
  final String neighborhood;
  final String city;
  final String stateCode;

  const Location({
    required this.cep,
    required this.place,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.stateCode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Location &&
        other.cep == cep &&
        other.place == place &&
        other.complement == complement &&
        other.neighborhood == neighborhood &&
        other.city == city &&
        other.stateCode == stateCode;
  }

  @override
  int get hashCode {
    return cep.hashCode ^
        place.hashCode ^
        complement.hashCode ^
        neighborhood.hashCode ^
        city.hashCode ^
        stateCode.hashCode;
  }
}
