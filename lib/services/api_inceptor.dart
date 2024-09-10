import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:linkdin_auth_test/services/auth_service.dart';

class ApiInceptor implements InterceptorContract {
  final storage = const FlutterSecureStorage();
  final AuthService authService = AuthService();

  Future<String> get togenOrEmpty async {
    var token = await storage.read(key: 'token');
    if (token == null) return "";
    return token;
  }

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    String token = await togenOrEmpty;

    try {
      request.headers['Authorization'] = 'Bearer $token';
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async {
    var refreshToken = await storage.read(key: 'refresh_token');
    if (response.statusCode == 401 && refreshToken != null) {
      var iResponse = await authService.refreshToken(refreshToken);
      var data = jsonDecode(iResponse!.body);
      await storage.write(key: 'token', value: data['access_token']);
      await storage.write(
        key: 'refresh_token',
        value: data['refresh_token'],
      );
    }
    return response;
  }
  
  @override
  FutureOr<bool> shouldInterceptRequest() {
    // TODO: implement shouldInterceptRequest
    throw UnimplementedError();
  }
  
  @override
  FutureOr<bool> shouldInterceptResponse() {
    // TODO: implement shouldInterceptResponse
    throw UnimplementedError();
  }


}


/* 
https://www.linkedin.com/oauth/v2/authorization?
client_id=7820aehx75152b
&response_type=code
&state=foobar
&scope=openid+profile+w_member_social+email
&redirect_uri=https://www.google.com
 */

