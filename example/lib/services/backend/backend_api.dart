import 'model/token_model.dart';

abstract class BackendApi {
  Future<TokenModel> getToken();
}