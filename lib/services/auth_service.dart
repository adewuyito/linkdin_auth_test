import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_interceptor/http_interceptor.dart' as http;
import 'package:linkdin_auth_test/helper/constants.dart';

class AuthService {
  var loginUrl = Uri.parse("${Constants.baseUrl}/outh/token");
  var registerUrl = Uri.parse("${Constants.baseUrl}/outh/signup");

  Dio dio = Dio();

  Future<http.Response?> login(String username, String password) async {
    String client = "";
    String secret = "";
    String basicAuth = 'Basic ${base64.encode(
      utf8.encode('$client:$secret'),
    )}';

    var response = await http.post(
      loginUrl,
      headers: {'authorization': basicAuth},
      body: {
        'username': username,
        'grant_type': 'password',
        'password': password,
      },
    );

    return response;
  }

  Future<Response?> linkedinLogin() async {
    // String client = "";
    // String secret = "";
    // String basicAuth = 'Basic ${base64.encode(
    //   utf8.encode('$client:$secret'),
    // )}';

    var response = await dio.get(
      "https://www.linkedin.com/oauth/v2/authorization",
      // headers: {'authorization': basicAuth},
      queryParameters: {
        "client_id": "7820aehx75152b",
        "response_type": "code",
        "state": "foobar",
        "scope": "openid+profile+w_member_social+email",
        "redirect_uri": "https://www.google.com",
      },
    );

    return response;
  }

  Future<http.Response?> refreshToken(String refreshToken) async {
    String client = "";
    String secret = "";
    String basicAuth = 'Basic ${base64.encode(
      utf8.encode('$client:$secret'),
    )}';

    var response = await http.post(loginUrl, headers: {
      'authorization': basicAuth
    }, body: {
      'refresh_token': refreshToken,
      'grant_type': 'refresh_token',
    });

    return response;
  }
}

final authorization_endpoint =
    "https://www.linkedin.com/oauth/v2/authorization";
final token_endpoint = "https://www.linkedin.com/oauth/v2/accessToken";
final userinfo_endpoint = "https://api.linkedin.com/v2/userinfo";



/* 
https://www.linkedin.com/oauth/v2/authorization?
client_id=7820aehx75152b
&response_type=code
&state=foobar
&scope=openid+profile+w_member_social+email
&redirect_uri=https://www.google.com
 */

