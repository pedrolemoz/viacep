import 'dart:convert';

import '../../domain/entities/location.dart';

class LocationMapper {
  static Map<String, dynamic> toMap(Location location) {
    return {
      'cep': location.cep,
      'logradouro': location.place,
      'complemento': location.complement,
      'bairro': location.neighborhood,
      'localidade': location.city,
      'uf': location.stateCode
    };
  }

  static Location fromMap(Map<String, dynamic> map) {
    return Location(
      cep: map['cep'] ?? '',
      place: map['logradouro'] ?? '',
      complement: map['complemento'] ?? '',
      neighborhood: map['bairro'] ?? '',
      city: map['localidade'] ?? '',
      stateCode: map['uf'] ?? '',
    );
  }

  static String toJSON(Location location) => json.encode(toMap(location));

  static Location fromJSON(String source) => fromMap(json.decode(source));
}
