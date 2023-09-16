import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twitter_clone/components/tweet_card.dart';
import 'package:twitter_clone/main.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _loadingAccountInfo = false;
  bool _loadingTweets = false;
  Map<String, dynamic> profileInfo = {};
  List accountTweets = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAccountTweets();
  }

  Future<void> _loadAccountTweets() async {
    setState(() {
      _loadingTweets = true;
    });
    try {
      var userId = supabase.auth.currentUser?.id;
      var rawAccountTweets = await supabase
          .from('tweets')
          .select<List<Map<String, dynamic>>>()
          .eq('owner', userId)
          .order('created_at');
      for (var tweet in rawAccountTweets) {
        accountTweets.add(TweetCard(tweetInfo: tweet, parentRoute: "/profile"));
        accountTweets.add(const Divider(color: dividerGrey));
      }
      print(accountTweets);
    } catch (error) {
      print("Loading account tweets error");
      print(error);
    } finally {
      setState(() {
        _loadingTweets = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingAccountInfo = true;
    });
    try {
      var userId = supabase.auth.currentUser?.id;
      profileInfo =
          await supabase.from('profiles').select('*').eq('id', userId).single();
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

  @override
  Widget build(BuildContext context) {
    return _loadingAccountInfo
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
              title: Text("Twitee"),
              backgroundColor: twitterBlue,
            ),
            body: Container(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  profileAndEdit(context),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileInfo['full_name'],
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "@${profileInfo['username']}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Divider(color: dividerGrey),
                      const Text(
                        "Tweet",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600),
                      ),
                      const Divider(color: dividerGrey),
                      _loadingTweets
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Column(children: [...accountTweets]),
                            )
                    ],
                  )
                ],
              ),
            ),
            backgroundColor: Colors.black,
          );
  }

  Row profileAndEdit(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 70,
          height: 70,
          child: const Icon(FontAwesomeIcons.user, size: 60),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/edit_profile');
          },
          child: const Text("Edit profile"),
        ),
      ],
    );
  }
}
