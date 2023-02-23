library flutter_utils;

class APIConfig {
  late String apiEndpoint;
  late String version;
  late String clientId;
  late String? tokenUrl;
  late String? profileUrl;
  late String? revokeTokenUrl;
  late String? grantType;

  APIConfig({
    required this.apiEndpoint,
    required this.clientId,
    this.version = "api/v1",
    this.tokenUrl = "auth/token/",
    this.revokeTokenUrl = "auth/revoke-token/",
    this.profileUrl = "api/v1/users/me/",
    this.grantType = "password",
  });

  @override
  String toString() {
    // TODO: implement toString
    return "${apiEndpoint} ${version} ${tokenUrl}";
  }
}
