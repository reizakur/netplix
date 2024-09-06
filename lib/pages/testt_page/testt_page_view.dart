part of '../pages.dart';

class TesttTwo extends StatefulWidget {
  const TesttTwo({super.key});

  @override
  _TesttTwoState createState() => _TesttTwoState();
}

class _TesttTwoState extends State<TesttTwo> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the YouTube player controller with the video URL
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        'https://www.youtube.com/watch?v=wVRnxFITGK0',
      )!,
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
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.list_alt_rounded),
        title: const Text('Netplix View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              Navigator.of(context).push(_createRoute());
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding to all sides
            child: Container(
              color: Colors.green,
              width: MediaQuery.of(context).size.width * 0.20,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  // Embedded YouTube video
                  Container(
                    color: Colors.yellow,
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.red,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  // Description of the video
                  Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.30,
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'This video provides an in-depth look into the topic and '
                      'explores the key concepts and features. It\'s designed '
                      'to give you a comprehensive understanding of the subject.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  // Buttons section
                  Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Data'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.10,
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Data'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy route function, replace with your actual route implementation
Route _createRoute() {
  return MaterialPageRoute(builder: (context) => Container());
}
