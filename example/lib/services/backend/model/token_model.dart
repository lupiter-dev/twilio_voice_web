class TokenModel {
  final String identity;
  final String token;

  TokenModel(this.identity, this.token);

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    json['identity'] as String,
    json['token'] as String,
  );

  Map<String, dynamic> toJson(TokenModel instance) =>
      <String, dynamic>{
        'identity': instance.identity,
        'token': instance.token,
      };
}
