import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signInWithYandex() async {
    final clientId = 'your-yandex-client-id';
    final clientSecret = 'your-yandex-client-secret';
    final redirectUri = 'https://your-app.com/oauth/callback';

    final url = 'https://oauth.yandex.ru/authorize?'
        'client_id=$clientId&'
        'redirect_uri=$redirectUri&'
        'response_type=code&'
        'scope=login%3Aemail';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  Future<void> _handleRedirectUri(String uri) async {
    final clientId = '8ad75c677a1b413aa8eaa82c993e3d6a';
    final clientSecret = '8496617dedc1461d854885d447e94875';
    final redirectUri = 'https://your-app.com/oauth/callback';
    final code = uri.split('code=')[1];
    final tokenResponse = await http.post(
      Uri.parse('https://oauth.yandex.ru/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    final token = json.decode(tokenResponse as String)['access_token'];

    final userResponse = await http.get(
      Uri.parse('https://login.yandex.ru/info?format=json&oauth_token=$token'),
    );

    final user = json.decode(userResponse as String);
    final email = user['email'];

    //final userResponse = await supabase. auth. signInWithOAuth(
    // OAuthProvider.yandex,
      // Use deep link to bring the user back to the app
    // redirectTo: 'my-scheme:// my-host/ callback-path',
    ///);

    if (userResponse.statusCode != 200) {
      print('Ошибка авторизации');
    } else {
      print('Авторизация успешна!');
    }
  }

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo:
        kIsWeb ? null : 'io.supabase.usrmng://login-callback/',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your email for a login link!')),
        );
        _emailController.clear();
      }
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        // ignore: use_build_context_synchronously
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        // ignore: use_build_context_synchronously
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('Sign in via the magic link with your email below'),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: Text(_isLoading ? 'Loading' : 'Send Magic Link'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _signInWithYandex,
            child: Text('Log in with Yandex'),
          )
        ],
      ),
    );
  }
}