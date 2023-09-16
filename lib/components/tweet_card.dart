// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:twitter_clone/main.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

class TweetCard extends StatefulWidget {
  TweetCard({super.key, required this.tweetInfo, required this.parentRoute});
  String parentRoute;
  Map<String, dynamic> tweetInfo;

  @override
  State<TweetCard> createState() => _TweetCardState();
}

class _TweetCardState extends State<TweetCard> {
  bool _isLoading = false;
  bool _errorFound = false;
  late Color likeIconColor = Colors.grey;
  late Color retweetIconColor = Colors.grey;
  // late Map<String, dynamic> retweetInstance;
  late List<dynamic> instance;
  late List likeInstance;
  late List retweetInstance;
  String userName = '';
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _updateLikeIconColor();
    _updateRetweetIconColor();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String userId = widget.tweetInfo['owner'];
      final List data = await supabase
          .from('profiles')
          .select<List<Map<String, dynamic>>>('*')
          .eq('id', userId);
      userName = data[0]['full_name'];
    } catch (error) {
      setState(() {
        print("Loading tweet owner content occur");
        print(error);
        _errorFound = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reloadTweet() async {
    try {
      var temp = await supabase
          .from('tweets')
          .select<List<Map<String, dynamic>>>('*')
          .eq('id', widget.tweetInfo['id']);
      widget.tweetInfo = temp[0];
    } catch (error) {
      print("reloading tweet error occur");
      print(error);
    }
  }

  Future<void> _retweet() async {
    try {
      int additionValue = 0;
      final tweetId = widget.tweetInfo['id'];
      instance = await supabase
          .from('retweets')
          .select<List>()
          .match({'tweet': tweetId, 'owner': supabase.auth.currentUser?.id});
      if (instance.isEmpty) {
        await supabase.from('retweets').insert({'tweet': tweetId});
        additionValue = 1;
      } else {
        await supabase.from('retweets').delete().eq('tweet', tweetId);
        additionValue = -1;
      }
      final int newRetweetNumber =
          widget.tweetInfo['retweet_number'] + additionValue;
      await supabase.from('tweets').upsert(
        {
          'id': tweetId,
          'owner': widget.tweetInfo['owner'],
          'content': widget.tweetInfo['content'],
          'retweet_number': newRetweetNumber
        },
        onConflict: 'id',
      );
      await _reloadTweet();
      await _updateRetweetIconColor();
    } catch (error) {
      print('retweet error occur');
      print(error);
    } finally {
      setState(() {});
    }
  }

  Future<void> _like() async {
    try {
      int additionValue = 0;
      final tweetId = widget.tweetInfo['id'];
      instance = await supabase
          .from('likes')
          .select<List>('*')
          .match({'tweet': tweetId, 'owner': supabase.auth.currentUser?.id});
      if (instance.isEmpty) {
        await supabase.from('likes').insert({'tweet': tweetId});
        additionValue = 1;
      } else {
        await supabase.from('likes').delete().eq('tweet', tweetId);
        additionValue = -1;
      }
      final int newLikeNumber = widget.tweetInfo['like_number'] + additionValue;
      await supabase.from('tweets').upsert(
        {
          'id': tweetId,
          'owner': widget.tweetInfo['owner'],
          'content': widget.tweetInfo['content'],
          'like_number': newLikeNumber
        },
        onConflict: 'id',
      );
      await _reloadTweet();
      await _updateLikeIconColor();
    } catch (error) {
      print('like error occur');
      print(error);
    } finally {
      setState(() {});
    }
  }

  Future<void> _updateLikeIconColor() async {
    try {
      likeInstance = await supabase
          .from('likes')
          .select('*')
          .eq('tweet', widget.tweetInfo['id'])
          .eq('owner', supabase.auth.currentUser?.id);
      likeIconColor = likeInstance.isEmpty ? Colors.grey : twitterBlue;
    } catch (error) {
      print("load like failed");
      print(error);
    } finally {
      setState(() {});
    }
  }

  Future<void> _updateRetweetIconColor() async {
    try {
      retweetInstance = await supabase
          .from('retweets')
          .select('*')
          .eq('tweet', widget.tweetInfo['id'])
          .eq('owner', supabase.auth.currentUser?.id);
      retweetIconColor = retweetInstance.isEmpty ? Colors.grey : twitterBlue;
    } catch (error) {
      print("load retweet failed");
      print(error);
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorFound) {
      // return Container(child: null);
      return const Text('There was an error');
    } else {
      return SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicture(),
            Container(
              // content part
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name and edit
                  nameAndEdit(context),
                  tweetContent(),
                  const SizedBox(height: 20),
                  tweetStat(),
                  // action
                  tweetFooter()
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget tweetContent() {
    return SizedBox(
      width: 350,
      child: ReadMoreText(
        widget.tweetInfo['content'],
        trimLines: 3,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'Show more',
        trimExpandedText: ' ...Show less',
        style: const TextStyle(fontSize: 18),
        moreStyle: const TextStyle(fontSize: 14, color: twitterBlue),
        colorClickableText: twitterBlue,
      ),
    );
  }

  SizedBox tweetFooter() {
    return SizedBox(
      height: 35,
      width: 350,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          widget.tweetInfo['created_at'].toString().substring(0, 10),
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              color: Colors.grey,
              onPressed: _retweet,
              icon: Icon(
                FontAwesomeIcons.retweet,
                color: retweetIconColor,
              ),
            ),
            IconButton(
              onPressed: _like,
              color: Colors.grey,
              icon: Icon(
                FontAwesomeIcons.heart,
                color: likeIconColor,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Row tweetStat() {
    return Row(
      // tweet summary
      children: [
        Text(
          widget.tweetInfo['retweet_number'].toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          " Retweets",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          widget.tweetInfo['like_number'].toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          " Likes",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  SizedBox nameAndEdit(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          widget.parentRoute == "/profile" ? moreMenu(context) : Container()
        ],
      ),
    );
  }

  Container moreMenu(BuildContext context) {
    return Container(
      child: widget.tweetInfo['owner'] == supabase.auth.currentUser?.id
          ? MenuAnchor(
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.more_horiz),
                  tooltip: 'Show menu',
                );
              },
              menuChildren: [
                MenuItemButton(
                    child: const Text("Update"),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed('/update_tweet');
                    }),
                MenuItemButton(
                  child: const Text("Delete"),
                  onPressed: () async {
                    try {
                      print('in delete');
                      await supabase
                          .from('tweets')
                          .delete()
                          .eq('id', widget.tweetInfo['id']);
                      await supabase
                          .from('retweets')
                          .delete()
                          .eq('tweet', widget.tweetInfo['id']);
                      await supabase
                          .from('likes')
                          .delete()
                          .eq('tweet', widget.tweetInfo['id']);
                      print('deleted');
                    } catch (error) {
                      print('delete error');
                      print(error);
                    } finally {
                      Navigator.of(context)
                          .pushReplacementNamed(widget.parentRoute);
                    }
                  },
                ),
              ],
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            )
          : null,
    );
  }

  Container profilePicture() {
    return Container(
      // profile part
      padding: const EdgeInsets.only(top: 5),
      child: const Icon(FontAwesomeIcons.user),
    );
  }
}
