import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter_clone/pages/edit_profile.dart';
import 'package:twitter_clone/pages/login.dart';
import 'package:twitter_clone/pages/profile.dart';
import 'package:twitter_clone/pages/splash_page.dart';
import 'package:twitter_clone/pages/tweeting.dart';
import 'package:twitter_clone/pages/wrapper.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

final supabase = Supabase.instance.client;
Future<void> main() async {
  await Supabase.initialize(
    url: 'https://gyravndizuijspxahntc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5cmF2bmRpenVpanNweGFobnRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQzNjIyMjcsImV4cCI6MjAwOTkzODIyN30.M0mbO5axEfJ81auydEwjD2Cl5FyIj3MargHbOe4AeiY',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: twitterBlue,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const WrapperPage(),
        '/tweet': (_) => const TweetingPage(),
        '/profile': (_) => const Profile(),
        '/edit_profile': (_) => const EditProfile(),
      },
    );
  }
}
