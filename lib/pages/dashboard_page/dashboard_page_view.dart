part of '../pages.dart';

class dashboardGuess extends StatelessWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final ValueNotifier<bool> _isCameraOpenNotifier = ValueNotifier<bool>(true);
  Timer? _inactivityTimer;
  static const int inactivityDuration =
      60; // 8 seconds for demo; adjust as needed
  final TestPrint testPrint = TestPrint();
  String? _lastScannedCode;
  bool _isScanning = false;
  dashboardGuess({Key? key}) : super(key: key) {
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: inactivityDuration), () {
      _closeCamera();
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _closeCamera() {
    _isCameraOpenNotifier.value = false;
  }

  void _openCamera() {
    _isCameraOpenNotifier.value = true;
    _resetInactivityTimer(); // Reset timer when camera is reopened
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardPageBloc, DashboardPageState>(
      listener: (context, state) {
        if (state is DashboardPageState) {
          if (state.status == PageStatus.dataguess) {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext _) {
              return BlocProvider(
                create: (context) => ListGuessPageBloc(context: context),
                child: ListGuessPage(),
              );
            }));
            // inputpindaikendaraan
          } else if (state.status == PageStatus.checkpop) {
            // Navigator.pop(context, 'Cancel');

            CheckOutSuccess(context);
          } else if (state.status == PageStatus.checkout) {
            // Navigator.pop(context, 'Cancel');

            CheckOutPop(context, state.findcode);
          } else if (state.status == PageStatus.gagal) {
            CheckOutFailed(context);
          } else if (state.status == PageStatus.checkoutCompleted) {
            // Close the dialog if checkout is completed
            Navigator.of(context).pop();
          } else if (state.status == PageStatus.dashboard) {
            _showLoadingDialog(context);

            // Delay for 1 second before navigating
            Future.delayed(Duration(seconds: 1), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext _) {
                return BlocProvider(
                  create: (context) => DashboardPageBloc(context: context),
                  child: dashboardGuess(),
                );
              }));
            });
          } else if (state.status == PageStatus.loadingpop) {
            _showLoadingDialog(context);
          } else if (state.status == PageStatus.loadingclose) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
//  Navigator.pushReplacement(context,
//       MaterialPageRoute(builder: (BuildContext _) {
//         return BlocProvider(
//           create: (context) => DashboardPageBloc(context: context),
//           child: dashboardGuess(),
//         );
//       }));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Surat Tamu'),
          // leading: Text('Surat Tamu'),
          actions: [
            IconButton(
              icon: Icon(Icons.print),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content:
                          BlocBuilder<DashboardPageBloc, DashboardPageState>(
                        builder: (context, state) {
                          return Container(
                            // color: Colors.black,
                            child: Container(
                              child: ListTile(
                                subtitle: DropdownButton<BluetoothDevice?>(
                                  items: state.devices.map((device) {
                                    return DropdownMenuItem<BluetoothDevice?>(
                                      value: device,
                                      child:
                                          Text(device.name ?? 'Unknown Device'),
                                    );
                                  }).toList(),
                                  onChanged: (BluetoothDevice? value) {
                                    BlocProvider.of<DashboardPageBloc>(context)
                                        .add(
                                      PendingTreatmentEventChangePrinter(
                                          value: value),
                                    );
                                  },
                                  value: state.selectedDevice,
                                ),
                                title: Text('Device:'),
                                trailing: ElevatedButton(
                                    onPressed: () {
                                      if (state.selectedDevice != null) {
                                        if (state.connected) {
                                          context
                                              .read<DashboardPageBloc>()
                                              .add(DisconnectBlue());
                                        } else {
                                          print(
                                              'erngga ${state.selectedDevice}');
                                          context.read<DashboardPageBloc>().add(
                                              ConnectBlue(
                                                  perangkat:
                                                      state.selectedDevice!));
                                          // Connect logic
                                          // _connect(context, state.selectedDevice!);
                                        }
                                      } else {
                                        // Handle no device selected
                                      }
                                    },
                                    child: Text('Connect')),
                                leading: ElevatedButton(
                                    onPressed: () {
                                      String receipt = "/align left"
                                          "\n**VisitorX**\n";
                                      testPrint.printCustom(receipt, '\x0A');
                                    },
                                    child: Text('Test')),
                              ),
                            ),
                          );
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.list_alt_outlined),
              onPressed: () {
                context.read<DashboardPageBloc>().add(ListGuestView());
                //
              },
            ),
          ],
        ),
        body: GestureDetector(
          onPanUpdate: (_) => _resetInactivityTimer(),
          onTap: () => _resetInactivityTimer(),
          child: ValueListenableBuilder<bool>(
            valueListenable: _isCameraOpenNotifier!,
            builder: (context, isCameraOpen, child) {
              return ListView(
                children: <Widget>[
                  if (isCameraOpen)
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.6, // Set height for QRView
                      child: QRView(
                        key: qrKey,
                        cameraFacing: CameraFacing.front,
                        onQRViewCreated: (controller) {
                          controller.scannedDataStream.listen((scanData) async {
                            if (!_isScanning && scanData.code != null) {
                              // Prevent duplicate scan processing
                              if (scanData.code != _lastScannedCode) {
                                _lastScannedCode = scanData.code;
                                _isScanning = true; // Set scanning flag

                                _closeCamera();

                                context.read<DashboardPageBloc>().add(
                                      ScanBarcode(
                                          code: scanData.code.toString()),
                                    );

                                // Set a delay before allowing another scan
                                await Future.delayed(Duration(seconds: 2));
                                _isScanning = false; // Reset scanning flag
                              }
                            }
                            _resetInactivityTimer(); // Reset timer on scan
                          });
                        },
                      ),
                    )
                  else
                    Center(
                      child: IconButton(
                        onPressed: _openCamera,
                        icon: Icon(Icons.qr_code_scanner, size: 300),
                      ),
                    ),
                  // SizedBox(height: 20), // Add some space between the QRView and the text
                  // Center(
                  //   child: Text(
                  //     'Scan QR Code di sini',
                  //     style: TextStyle(fontSize: 16),
                  //   ),
                  // ),
                  // Container(
                  //   color: Colors.black,
                  //   width: MediaQuery.of(context).size.width,
                  //   height: MediaQuery.of(context).size.height * 0.20,
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  void printCustom(String text, String lineBreak) async {
    String customData = '$text$lineBreak';
    final leftAlign = '\x1B\x61\x00';
    final centerAlign = '\x1B\x61\x01';
    final rightAlign = '\x1B\x61\x02';

    text = text.replaceAll('/align left', leftAlign);
    text = text.replaceAll('/align center', centerAlign);
    text = text.replaceAll('/align right', rightAlign);
    try {
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected == true) {
        bluetooth.write(text);
        // bluetooth.paperCut();
      } else {}
    } catch (error) {}
  }
}

void CheckOutSuccess(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Berhasi Check Out'),
        // content: Text('ID anda tidak terdaftar.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
//

void CheckOutPop(BuildContext context, Map<String, dynamic>? findcode) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(findcode?['check_out'] == 0
            ? 'Check Out'
            : 'Success'), // Menggunakan data dari findcode
        content: Text(
          'ID Guess: ${findcode?['id_guess']}\n'
          'Check In: ${findcode?['check_in']}\n'
          'Check Out: ${findcode?['check_out']}\n'
          'Name: ${findcode?['guess_name']}\n'
          'Company: ${findcode?['company']}\n'
          'Plate Number: ${findcode?['plate_number']}\n'
          'Employee Name: ${findcode?['employe_name']}\n'
          'Permission: ${findcode?['permission']}\n'
          'Need For: ${findcode?['need_for']}\n'
          'Notes: ${findcode?['notes']}\n'
          'Path Card: ${findcode?['path_card']}\n'
          'Created At: ${findcode?['created_at']}',
          style: TextStyle(fontSize: 16), // Adjust the font size as needed
        ),
        actions: <Widget>[
          if (findcode?['check_out'] == 0)
            TextButton(
              onPressed: () {
                context.read<DashboardPageBloc>().add(CheckOuts(
                    id_guess:
                        findcode?['id_guess'].toString())); // Trigger checkout
              },
              child: Text('Check Out'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text(findcode?['check_out'] == 0 ? 'Cancel' : 'Oke'),
          ),
        ],
      );
    },
  );
}

void CheckOutFailed(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Gagal Check Out'),
        content: Text('ID anda tidak terdaftar.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Loading..."),
            ],
          ),
        ),
      );
    },
  );
}
