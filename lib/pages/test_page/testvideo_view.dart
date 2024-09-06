part of '../pages.dart';

class TestFirst extends StatelessWidget {
  final List<String> imageUrls = [
    'https://ghmoviefreak.com/wp-content/uploads/2017/09/running-banner.png',
    'https://zengrrl.com/wp-content/uploads/2020/11/hulu-run-banner.jpg',
    'https://static.promediateknologi.id/crop/0x0:0x0/0x0/webp/photo/akuratco/images/akurat_20200526051715_5JWO46.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.list_alt_rounded),
        title: Text('Netplix'),
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined),
            onPressed: () {
              Navigator.of(context).push(_createRoutes());
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Carousel Slider
          _buildCarouselSlider(),

          // Horizontal ListView with BlocBuilder
          _buildHorizontalListViewWithBloc(context),

          // Horizontal ListView with Sample Data
          _buildSampleHorizontalListView(context),
        ],
      ),
    );
  }

  Widget _buildCarouselSlider() {
    return Container(
      color: Colors.blue,
      width: double.infinity,
      height: 200,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
        ),
        items: imageUrls.map((url) {
          return Container(
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalListViewWithBloc(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: 200,
      child: BlocBuilder<TestvideoBloc, TestvideoState>(
        builder: (context, state) {
          // Handling state.data is empty or not fetched yet
          if (state.datas.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          // Display fetched data
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.datas.length,
            itemBuilder: (context, index) {
              final item = state.datas[index];
              return SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TesttTwo(),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        // Display the image from the online link
                        Image.network(
                          item.companY,
                          width: 150, // Width of the image (adjust as needed)
                          height: 100, // Height of the image (adjust as needed)
                          fit: BoxFit
                              .cover, // Adjusts the image to cover the Card area
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback widget if the image fails to load
                            return Icon(Icons.error, color: Colors.red);
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              item.employeName, // Displaying the 'employeName' field
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
// Widget _buildSampleHorizontalListView(BuildContext context) {

  Widget _buildSampleHorizontalListView(BuildContext context) {
    return Container(
      color: Colors.yellow,
      width: double.infinity,
      height: 300,
      child: BlocBuilder<TestvideoBloc, TestvideoState>(
        builder: (context, state) {
          if (state.datas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0), // Padding around the grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 8.0, // Spacing between columns
              mainAxisSpacing: 8.0, // Spacing between rows
              childAspectRatio: 2 / 3, // Aspect ratio of each grid item
            ),
            itemCount: state.datas.length,
            itemBuilder: (context, index) {
              final item = state.datas[index];
              return Card(
                clipBehavior:
                    Clip.antiAlias, // Ensure images are clipped within the card
                child: Column(
                  children: [
                    // Display image from URL
                    Expanded(
                      child: item.companY != null && item.companY.isNotEmpty
                          ? Image.network(
                              item.companY,
                              fit: BoxFit
                                  .cover, // Adjust how the image fits in the container
                              errorBuilder: (context, error, stackTrace) {
                                // Handle error when the image cannot be loaded
                                return const Icon(Icons.broken_image, size: 50);
                              },
                            )
                          : const Icon(Icons.image,
                              size: 50), // Placeholder if no image URL
                    ),
                    const SizedBox(height: 8),
                    // Display company name or description
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.employeName, // Assuming this field contains the text data
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Route _createRoutes() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SearchPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white60),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<TestvideoBloc, TestvideoState>(
        builder: (context, state) {
          if (state.datas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0), // Padding around the grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 8.0, // Spacing between columns
              mainAxisSpacing: 8.0, // Spacing between rows
              childAspectRatio: 2 / 3, // Aspect ratio of each grid item
            ),
            itemCount: state.datas.length,
            itemBuilder: (context, index) {
              final item = state.datas[index];
              return Card(
                clipBehavior:
                    Clip.antiAlias, // Ensure images are clipped within the card
                child: Column(
                  children: [
                    // Display image from URL
                    Expanded(
                      child: item.companY != null && item.companY.isNotEmpty
                          ? Image.network(
                              item.companY,
                              fit: BoxFit
                                  .cover, // Adjust how the image fits in the container
                              errorBuilder: (context, error, stackTrace) {
                                // Handle error when the image cannot be loaded
                                return const Icon(Icons.broken_image, size: 50);
                              },
                            )
                          : const Icon(Icons.image,
                              size: 50), // Placeholder if no image URL
                    ),
                    const SizedBox(height: 8),
                    // Display company name or description
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.employeName, // Assuming this field contains the text data
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
