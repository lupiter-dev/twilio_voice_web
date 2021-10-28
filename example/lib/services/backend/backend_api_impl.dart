import 'dart:convert';

import 'package:http/http.dart';

import 'backend_api.dart';
import 'model/token_model.dart';

class BackendApiImpl extends BackendApi {
  @override
  Future<TokenModel> getToken() async {
    final response = await get(Uri.parse('http://localhost:8080/token'));
    final tokenModel = TokenModel.fromJson(jsonDecode(response.body));
    return tokenModel;
  }
}
