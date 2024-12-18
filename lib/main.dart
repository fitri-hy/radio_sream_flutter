import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Stream',
      home: RadioListScreen(),
    );
  }
}

class RadioListScreen extends StatefulWidget {
  @override
  _RadioListScreenState createState() => _RadioListScreenState();
}

class _RadioListScreenState extends State<RadioListScreen> {
  List<dynamic> radioList = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentStreamUrl = "";
  String currentTrack = '';
  String name = '';
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchRadioList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchRadioList();
      }
    });
  }

  Future<void> fetchRadioList() async {
    final response = await http.get(Uri.parse('https://api.i-as.dev/api/radio?page=$currentPage'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        radioList.addAll(data);
      });
      currentPage++;
    } else {
      throw Exception('Failed to load radio data');
    }
  }

  void _playStream(String streamUrl, String track, String radioName) {
    setState(() {
      currentStreamUrl = streamUrl;
      isPlaying = true;
      currentTrack = track;
      name = radioName;
    });
    _audioPlayer.play(UrlSource(streamUrl));
  }

  void _pauseStream() {
    setState(() {
      isPlaying = false;
      currentTrack = '';
      name = '';
    });
    _audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
		appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/logo.png', height: 25),
              SizedBox(width: 10),
              Text(
                'Radio Stream',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: radioList.length,
          itemBuilder: (context, index) {
            final radio = radioList[index];
            return Card(
              child: ListTile(
                //leading: Image.network(
                //  'https://cdn-icons-png.flaticon.com/256/4787/4787623.png',
                //  fit: BoxFit.cover,
                //),
                title: Text(
                  radio['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.music_note, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${radio['currentTrack']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${radio['listeners']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${radio['like']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
				trailing: Container(
				  decoration: BoxDecoration(
					color: Colors.blue,
					borderRadius: BorderRadius.circular(50),
				  ),
				  padding: EdgeInsets.all(0),
				  child: IconButton(
					icon: Icon(Icons.play_arrow, color: Colors.white),
					onPressed: !isPlaying ? () {
					  _playStream(radio['streamUrl'], radio['currentTrack'], radio['name']);
					} : null,
				  ),
				),

              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentTrack.isNotEmpty && name.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
				child: Row(
				  mainAxisAlignment: MainAxisAlignment.spaceBetween,
				  crossAxisAlignment: CrossAxisAlignment.center,
				  children: [
					Column(
					  crossAxisAlignment: CrossAxisAlignment.start,
					  children: [
						Container(
						  width: 0.7 * MediaQuery.of(context).size.width, // 70% dari layar
						  child: Text(
							'$name',
							style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
							maxLines: 1,
							overflow: TextOverflow.ellipsis,
						  ),
						),
						Container(
						  width: 0.7 * MediaQuery.of(context).size.width, // 70% dari layar
						  child: Text(
							'$currentTrack',
							style: TextStyle(fontSize: 14),
							maxLines: 1,
							overflow: TextOverflow.ellipsis,
						  ),
						),
					  ],
					),
					IconButton(
					  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
					  color: Colors.white,
					  splashRadius: 30,
					  onPressed: () {
						if (isPlaying) {
						  _pauseStream();
						} else if (currentStreamUrl.isNotEmpty) {
						  _playStream(currentStreamUrl, currentTrack, name);
						}
					  },
					  padding: EdgeInsets.all(5),
					  constraints: BoxConstraints(
						minHeight: 25,
						minWidth: 25,
					  ),
					  style: IconButton.styleFrom(
						backgroundColor: Colors.blue,
						shape: CircleBorder(),
					  ),
					),
				  ],
				),

              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: currentPage > 1 ? () {
                    setState(() {
                      currentPage--;
                      radioList.clear();
                      fetchRadioList();
                    });
                  } : null,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      currentPage++;
                      radioList.clear();
                      fetchRadioList();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
