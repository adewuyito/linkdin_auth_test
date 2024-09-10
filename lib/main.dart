import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LinkedInLoginPage(),
    );
  }
}

class X extends ConsumerStatefulWidget {
  const X({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _XState();
}

class _XState extends ConsumerState<X> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // final authService = AuthService();

            // final response = await authService.linkedinLogin();

            // debugPrint("Response data => ${response!.data}");
            LinkedInAuth()
                .startLinkedInSignIn(); // To launch LinkedIn sign-in URL
            // LinkedInCallbackHandler(); // To handle deep link callback and token exchange

            print("Working button");
          },
          child: Text("login"),
        ),
      ),
    );
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

class LinkedInAuth {
  final String clientId = '7820aehx75152b';
  final String redirectUri =
      'https://www.google.com'; // Use your app scheme here
  final String scope = 'openid+profile+w_member_social+email';
  final String state = 'foobar';

  Future<void> startLinkedInSignIn() async {
    final authUrl =
        'https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&state=$state&scope=$scope';

    if (await canLaunchUrl(Uri.parse(authUrl))) {
      await launchUrl(Uri.parse(authUrl));
    } else {
      throw 'Could not launch LinkedIn authorization URL';
    }
  }
}

/* class LinkedInCallbackHandler {
  final AppLinks _appLinks = AppLinks();
  final String clientId = '7820aehx75152b';
  final String clientSecret = 'fzaSNoB6qsYX2mCh';
  final String redirectUri =
      'https://www.linkedin.com/developers/tools/oauth/redirect';

  LinkedInCallbackHandler() {
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    // _appLinks.getInitialAppLink().then(_handleDeepLink);
    _appLinks.getInitialLink().then(_handleDeepLink);
    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri? uri) {
    if (uri != null && uri.toString().startsWith(redirectUri)) {
      final code = uri.queryParameters['code'];
      if (code != null) {
        _exchangeCodeForToken(code);
      }
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final dio = Dio();
    final tokenUrl = 'https://www.linkedin.com/oauth/v2/accessToken';

    final response = await dio.post(tokenUrl, data: {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'client_secret': clientSecret,
    });

    if (response.statusCode == 200) {
      final accessToken = response.data['access_token'];
      print('Access token: $accessToken');
      // Store the access token securely, e.g., in flutter_secure_storage
    } else {
      print('Failed to exchange code for token');
    }
  }
}
 */

class LinkedInLoginPage extends StatefulWidget {
  @override
  _LinkedInLoginPageState createState() => _LinkedInLoginPageState();
}

class _LinkedInLoginPageState extends State<LinkedInLoginPage> {
  final LinkedInAuth _linkedInAuth = LinkedInAuth();
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    LinkedInCallbackHandler(onTokenReceived: (token) {
      setState(() {
        _accessToken = token;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LinkedIn Auth Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _accessToken == null
                ? ElevatedButton(
                    onPressed: _linkedInAuth.startLinkedInSignIn,
                    child: Text('Sign in with LinkedIn'),
                  )
                : Column(
                    children: [
                      Text(
                        'Access Token:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(_accessToken!),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class LinkedInCallbackHandler {
  final AppLinks _appLinks = AppLinks();
  final String clientId = '7820aehx75152b';
  final String clientSecret = 'fzaSNoB6qsYX2mCh';
  final String redirectUri = 'https://www.google.com';

  final void Function(String accessToken) onTokenReceived;

  LinkedInCallbackHandler({required this.onTokenReceived}) {
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    _appLinks.getInitialLink().then(_handleDeepLink);
    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri? uri) {
    if (uri != null && uri.scheme == 'myapp' && uri.host == 'auth') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        _exchangeCodeForToken(code);
      }
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final dio = Dio();
    final tokenUrl = 'https://www.linkedin.com/oauth/v2/accessToken';

    final response = await dio.post(tokenUrl, data: {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'client_secret': clientSecret,
    });

    if (response.statusCode == 200) {
      final accessToken = response.data['access_token'];
      onTokenReceived(accessToken);
    } else {
      print('Failed to exchange code for token');
    }
  }
}
