import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  List<String> videoIds = [
    'nPt8bK2gbaU',  // Add your YouTube video IDs here
    'iLnmTe5Q2Qw',
    'S0Q4gqBUs7c',
    'YE7VzlLtp-4',
    'hY7m5jjJ9mM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutorial Videos'),
      ),
      body: ListView.builder(
        itemCount: videoIds.length,
        itemBuilder: (context, index) {
          String videoId = videoIds[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: YoutubeVideoWidget(videoId: videoId),
          );
        },
      ),
    );
  }
}

class YoutubeVideoWidget extends StatefulWidget {
  final String videoId;

  YoutubeVideoWidget({required this.videoId});

  @override
  _YoutubeVideoWidgetState createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _showFullScreenVideo();
          },
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            thumbnail: Image.network(
              YoutubePlayer.getThumbnail(videoId: widget.videoId),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _showFullScreenVideo() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: YoutubePlayer(
            controller: _controller,
            width: MediaQuery.of(context).size.width,
            showVideoProgressIndicator: true,
            onReady: () {
              _controller.play();
            },
          ),
        ),
      );
    }));
  }
}
