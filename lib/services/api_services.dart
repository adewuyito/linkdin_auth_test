import 'package:http_interceptor/http_interceptor.dart';
import 'package:linkdin_auth_test/services/api_inceptor.dart';
import 'package:linkdin_auth_test/helper/constants.dart';

class ApiServices {
  Client client = InterceptedClient.build(interceptors: [ApiInceptor()]);

  Future<Response> getSecretArea() async {
    var secretUrl = Uri.parse("${Constants.baseUrl}/secret");
    final response = await client.get(secretUrl);
    return response;
  }
}
