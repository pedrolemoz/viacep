class GetLocationByCEPParameters {
  final String cep;

  const GetLocationByCEPParameters({required this.cep});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetLocationByCEPParameters && other.cep == cep;
  }

  @override
  int get hashCode => cep.hashCode;
}
