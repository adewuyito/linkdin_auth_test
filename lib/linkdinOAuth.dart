// ignore: file_names
import 'package:flutter/material.dart';
import 'package:linkedin_login/linkedin_login.dart';

@immutable
class LinkdinAuth {
  final String redirectUrl = 'YOUR-REDIRECT-URL';
  final String clientId = 'YOUR-CLIENT-ID';
  final String clientSecret = 'YOUR-CLIENT-SECRET';
}

// @TODO IMPORTANT - you need to change variable values below
// You need to add your own data from LinkedIn application
// From: https://www.linkedin.com/developers/
// Please read step 1 from this link https://developer.linkedin.com/docs/oauth2
const String redirectUrl =
    'https://www.linkedin.com/developers/tools/oauth/redirect';
const String clientId = '7820aehx75152b';
const String clientSecret = 'fzaSNoB6qsYX2mCh';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Flutter LinkedIn demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.person),
                  text: 'Profile',
                ),
                Tab(icon: Icon(Icons.text_fields), text: 'Auth code'),
              ],
            ),
            title: const Text('LinkedIn Authorization'),
          ),
          body: const TabBarView(
            children: [
              LinkedInProfileExamplePage(),
              LinkedInAuthCodeExamplePage(),
            ],
          ),
        ),
      ),
    );
  }
}

class LinkedInProfileExamplePage extends StatefulWidget {
  const LinkedInProfileExamplePage({super.key});

  @override
  State createState() => _LinkedInProfileExamplePageState();
}

class _LinkedInProfileExamplePageState
    extends State<LinkedInProfileExamplePage> {
  UserObject? user;
  bool logoutUser = false;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          LinkedInButtonStandardWidget(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (final BuildContext context) => LinkedInUserWidget(
                    appBar: AppBar(
                      title: const Text('OAuth User'),
                    ),
                    destroySession: logoutUser,
                    redirectUrl: redirectUrl,
                    clientId: clientId,
                    clientSecret: clientSecret,
                    onError: (final UserFailedAction e) {
                      print('Error: ${e.toString()}');
                      print('Error: ${e.stackTrace.toString()}');
                    },
                    onGetUserProfile: (final UserSucceededAction linkedInUser) {
                      print(
                        'Access token ${linkedInUser.user.token}',
                      );

                      print('User sub: ${linkedInUser.user.sub}');

                      user = UserObject(
                        firstName: linkedInUser.user.givenName,
                        lastName: linkedInUser.user.familyName,
                        email: linkedInUser.user.email,
                        profileImageUrl: linkedInUser.user.picture,
                      );

                      setState(() {
                        logoutUser = false;
                      });

                      Navigator.pop(context);
                    },
                    useVirtualDisplay: true,
                  ),
                  fullscreenDialog: false,
                ),
              );
            },
          ),
          LinkedInButtonStandardWidget(
            onTap: () {
              setState(() {
                user = null;
                logoutUser = true;
              });
            },
            buttonText: 'Logout',
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('First: ${user?.firstName} '),
              Text('Last: ${user?.lastName} '),
              Text('Email: ${user?.email}'),
              Text('Profile image: ${user?.profileImageUrl}'),
            ],
          ),
        ],
      ),
    );
  }
}

class LinkedInAuthCodeExamplePage extends StatefulWidget {
  const LinkedInAuthCodeExamplePage({super.key});

  @override
  State createState() => _LinkedInAuthCodeExamplePageState();
}

class _LinkedInAuthCodeExamplePageState
    extends State<LinkedInAuthCodeExamplePage> {
  AuthCodeObject? authorizationCode;
  bool logoutUser = false;

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LinkedInButtonStandardWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (final BuildContext context) => LinkedInAuthCodeWidget(
                  destroySession: logoutUser,
                  redirectUrl: redirectUrl,
                  clientId: clientId,
                  onError: (final AuthorizationFailedAction e) {
                    print('Error: ${e.toString()}');
                    print('Error: ${e.stackTrace.toString()}');
                  },
                  onGetAuthCode: (final AuthorizationSucceededAction response) {
                    print('Auth code ${response.codeResponse.code}');

                    print('State: ${response.codeResponse.state}');

                    authorizationCode = AuthCodeObject(
                      code: response.codeResponse.code,
                      state: response.codeResponse.state,
                    );
                    setState(() {});

                    Navigator.pop(context);
                  },
                ),
                fullscreenDialog: true,
              ),
            );
          },
        ),
        LinkedInButtonStandardWidget(
          onTap: () {
            setState(() {
              authorizationCode = null;
              logoutUser = true;
            });
          },
          buttonText: 'Logout user',
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Auth code: ${authorizationCode?.code} '),
              Text('State: ${authorizationCode?.state} '),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthCodeObject {
  AuthCodeObject({required this.code, required this.state});

  final String? code;
  final String? state;
}

class UserObject {
  UserObject({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImageUrl,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImageUrl;
}

const String uriRequest = '''
GET 
    https://www.linkedin.com/oauth/v2/authorization
    ?response_type=code
    &client_id={your_client_id}
    &redirect_uri={your_callback_url}
    &state=foobar
    &scope=liteprofile%20emailaddress%20w_member_social
    ''';

const String onRedirect =
    "https://dev.example.com/auth/linkedin/callback?state=foobar&code=AQTQmah11lalyH65DAIivsjsAQV5P-1VTVVebnLl_SCiyMXoIjDmJ4s6rO1VBGP5Hx2542KaR_eNawkrWiCiAGxIaV-TCK-mkxDISDak08tdaBzgUYfnTJL1fHRoDWCcC2L6LXBCR_z2XHzeWSuqTkR1_jO8CeV9E_WshsJBgE-PWElyvsmfuEXLQbCLfj8CHasuLafFpGb0glO4d7M";
