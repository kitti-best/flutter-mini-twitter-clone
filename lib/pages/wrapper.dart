import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter_clone/main.dart';
import 'package:twitter_clone/pages/home.dart';
import 'package:twitter_clone/pages/search.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  int _currentIndex = 0;

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: drawer(),
      appBar: AppBar(
        backgroundColor: twitterBlue,
        title: const Text("Twitee"),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: [
          const Home(),
          const Search(),
          const Placeholder(),
          const Placeholder()
        ][_currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/tweet');
        },
        backgroundColor: twitterBlue,
        child: const Icon(Icons.create, color: Colors.white),
      ),
      bottomNavigationBar: bottomNavigator(),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: twitterBlue),
            child: Text(
              "Twitee",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.user),
            title: const Text(
              "View profile",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text(
              "Sign out",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  BottomNavigationBar bottomNavigator() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _currentIndex == 0 ? twitterBlue : Colors.white,
            ),
            label: "Home",
            backgroundColor: Colors.black),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _currentIndex == 1 ? twitterBlue : Colors.white,
            ),
            label: "Search",
            backgroundColor: Colors.black),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_outlined,
              color: _currentIndex == 2 ? twitterBlue : Colors.white,
            ),
            label: "Notification",
            backgroundColor: Colors.black),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.mail_outline,
              color: _currentIndex == 3 ? twitterBlue : Colors.white,
            ),
            label: "Messages",
            backgroundColor: Colors.black),
      ],
      selectedItemColor: twitterBlue,
      backgroundColor: Colors.black,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
