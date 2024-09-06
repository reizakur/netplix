part of '../pages.dart';
class ListGuessPage extends StatelessWidget {
  // const ListGuessPage({super.key});
  late Size ukuranlayar;

  ListGuessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _textPencarian = TextEditingController();

    ukuranlayar = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjust horizontal padding
          child: Container(
            width: 250, // Set a width that fits well in the AppBar
            child: TextField(
              
              controller: _textPencarian,
              onChanged: (val) {
                context.read<ListGuessPageBloc>().add(PencarianDatas(kalimat: val));
              },
            ),
          ),
        ),
        actions: [

          // Add any other action widgets here if needed
        ],
      ),
      body: BlocBuilder<ListGuessPageBloc, ListGuessPageState>(
        builder: (context, state) {
          final dataToShow = state.serchProduk.isEmpty ? state.datas : state.serchProduk;

          return ListView(
            children: dataToShow.map((e) {
              final path = e.pathCard?.replaceFirst('File: ', '').replaceAll('\'', '') ?? '';

              return Card(
                // color: Colors.blue[],
                child: ExpansionTile(
    title: RichText(
  text: TextSpan(
    style: DefaultTextStyle.of(context).style,
    children: <TextSpan>[
      TextSpan(text: '${e.needfoR} - ${e.guessName} '),
      TextSpan(
        text: e.checkOut == '0' ? '|| Belum' : '|| Selesai',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
),
                  subtitle: Text('${e.id_guess} | ${e.checkIn} / ${e.checkOut}'),
                  leading:   IconButton(
                    onPressed: () {
                      context.read<ListGuessPageBloc>().add(Reprint(id_guess: e.id_guess));
                    },
                    icon: Icon(Icons.print),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           e.checkOut == '0'
                      ? TextButton(
                          onPressed: () {
                            context.read<ListGuessPageBloc>().add(CheckOutslist(id_guess: e.id_guess));
                          },
                          child: Text('Check Out'),
                        )
                      : Chip(
                          label: Text('Success', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.blue,
                        ),
                       
                          Container(
                            width: double.infinity,
                            child: Text(
                              'ID TAMU: ${e.id_guess}',
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Jam In/Out : ${e.checkIn} / ${e.checkOut == '0' ? '-' : e.checkOut}',
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          path.isNotEmpty && File(path).existsSync()
                              ? Image.file(File(path))
                              : Text('No image available'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}