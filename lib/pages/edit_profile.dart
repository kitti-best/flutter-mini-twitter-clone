import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter_clone/main.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _loadingAccountInfo = false;
  bool _updatingProfile = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  Map<String, dynamic> profileInfo = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingAccountInfo = true;
    });
    try {
      var userId = supabase.auth.currentUser?.id;
      profileInfo =
          await supabase.from('profiles').select('*').eq('id', userId).single();
      _fullnameController.text = profileInfo['full_name'];
      _usernameController.text = profileInfo['username'];
      print(profileInfo);
    } catch (error) {
      print("Loading profile error");
      print(error);
    } finally {
      setState(() {
        _loadingAccountInfo = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _updatingProfile = true;
    });
    try {
      var newFullname = _fullnameController.text.trim();
      var newUserName = _usernameController.text.trim();
      await supabase.from('profiles').upsert({
        'id': supabase.auth.currentUser?.id,
        'full_name': newFullname,
        'username': newUserName,
      }, onConflict: 'id');
    } catch (error) {
      print('update profile error');
      print(error);
    } finally {
      setState(() {
        _updatingProfile = false;
        Navigator.of(context).pushReplacementNamed('/profile');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loadingAccountInfo | _updatingProfile
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text("Edit profile"),
              backgroundColor: twitterBlue,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/profile');
                },
              ),
              actions: [
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: twitterBlue),
                    onPressed: _updateProfile,
                    child: const Text("Save"))
              ],
            ),
            body: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(FontAwesomeIcons.user),
                  const SizedBox(height: 20),
                  const Text(
                    'Fullname',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextFormField(
                    controller: _fullnameController,
                  ),
                  const Text(
                    'Username',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextFormField(
                    controller: _usernameController,
                  )
                ],
              ),
            ),
          );
  }
}
