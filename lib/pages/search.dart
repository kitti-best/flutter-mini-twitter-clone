import 'package:flutter/material.dart';
import 'package:twitter_clone/components/tweet_card.dart';
import 'package:twitter_clone/main.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool _loading = false;
  List data = [];
  final SearchController _keyword = SearchController();

  @override
  initState() {
    super.initState();
  }

  Future<void> _searchTweets(String kw) async {
    setState(() {
      _loading = true;
    });
    try {
      data = await supabase
          .from('tweets')
          .select<List<Map<String, dynamic>>>('*')
          .like('content', '%$kw%')
          .order('created_at', ascending: false);
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
    return tweetCards.isEmpty
        ? [
            SizedBox(
              height: 700,
              child: Center(
                child: Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text("Empty")),
              ),
            )
          ]
        : tweetCards;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 40,
          child: SearchBar(
              controller: _keyword,
              hintText: "Search here",
              onSubmitted: (kw) {
                print(kw);
                _searchTweets(kw);
                setState(() {});
              }),
        ),
        ..._createTweetCard()
      ],
    );
  }
}
