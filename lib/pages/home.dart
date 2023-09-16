import 'package:flutter/material.dart';
import 'package:twitter_clone/components/tweet_card.dart';
import 'package:twitter_clone/main.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;
  late List<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    _getTweets();
  }

  Future<void> _getTweets() async {
    setState(() {
      _loading = true;
    });
    try {
      data = await supabase
          .from('tweets')
          .select<List<Map<String, dynamic>>>('*')
          .order('created_at', ascending: false)
          .limit(100);
    } catch (error) {
      print("Error in loading tweets occur");
      print(error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List _createTweetCard() {
    List tweetCards = [];
    for (var tweetInfo in data) {
      tweetCards.add(TweetCard(tweetInfo: tweetInfo, parentRoute: "/home"));
      tweetCards.add(const Divider(color: dividerGrey));
    }
    return tweetCards;
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [..._createTweetCard()],
            ),
          );
  }
}
