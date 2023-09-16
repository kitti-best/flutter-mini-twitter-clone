import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter_clone/main.dart';
import 'package:twitter_clone/utils/custom_colors.dart';

class TweetingPage extends StatefulWidget {
  const TweetingPage({super.key});

  @override
  State<TweetingPage> createState() => _TweetingPageState();
}

class _TweetingPageState extends State<TweetingPage> {
  late final TextEditingController _contentController = TextEditingController();
  bool _isSaving = false;
  final _client = Supabase.instance.client;
  Future<void> _saveContent() async {
    setState(() {
      _isSaving = true;
    });
    try {
      print(_contentController.text.toString());
      await _client.from('tweets').insert(
        {'content': _contentController.text.toString()},
      );
    } on PostgrestException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unexpected Error occur"),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: twitterBlue,
        title: const Text("Create your tweet"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed("/home");
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: _saveContent,
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isSaving ? Colors.blueGrey[100] : twitterBlue),
            child: Text(_isSaving ? "Saving" : "Tweet"),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          const Text(
            "What are you thinking",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 120,
            child: TextField(
              // autofocus: true,
              controller: _contentController,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                fillColor: Colors.black,
                border: InputBorder.none,
                // filled: true,

                hintText: 'Enter a message',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
