class ViaCEPEndpoints {
  static String getLocationByCEP(String cep) =>
      'https://viacep.com.br/ws/$cep/json/';
}
