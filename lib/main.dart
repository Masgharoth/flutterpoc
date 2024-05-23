import 'package:flutter/material.dart'; //all the client id and domain info obfuscated here
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterpoc/discovery.dart';
import 'package:native_oauth2/native_oauth2.dart';
import 'package:pkce/pkce.dart';

const FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _nativeOAuth2Plugin = NativeOAuth2();

  bool loading = false;

  final authority = FUSIONAUTH_DOMAIN;
  final path = authorizationurl;
  final clientId = FUSIONAUTH_CLIENT_ID;
  final redirectUri = redirecturl;
  final scope = ['openid', 'email', 'profile', 'offline_access'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (kIsWeb) {
        final sameTabAuthentication = nativeOAuth2SameTabAuthResult;
        final redirect = sameTabAuthentication.redirect;

        if (redirect.toString().startsWith(redirectUri.toString())) {
          showSimpleDialog(sameTabAuthentication);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native OAuth2 Example App'),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            if (loading) {
              return const CircularProgressIndicator();
            } else {
              return ElevatedButton(
                onPressed: () => login(context),
                child: const Text('LOGIN'),
              );
            }
          },
        ),
      ),
    );
  }

  void login(BuildContext context) async {
    final provider = OAuthProvider(
      authUrlAuthority: authority,
      authUrlPath: path,
      clientId: clientId,
    );

    final pkcePair = PkcePair.generate();

    try {
      setState(() {
        loading = true;
      });

      final response = await _nativeOAuth2Plugin.authenticate(
          provider: provider,
          redirectUri: redirectUri,
          scope: scope,
          codeChallenge: pkcePair.codeChallenge,
          codeChallengeMethod: 'S256',
          prompt: 'select_account',
          webMode: const WebAuthenticationMode.sameTab());

      if (!mounted) return;

      showSimpleDialog(response);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void showSimpleDialog(Object? obj) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(obj.toString()),
      ),
    );
  }
}
