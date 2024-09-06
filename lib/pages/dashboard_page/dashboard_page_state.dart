part of 'dashboard_page_bloc.dart';

enum PageStatus {
  idle,
  inputkendaraan,
  listguess,
  dataguess,
  checkout,
  checkpop,
  checkoutready,
  loadingpop,
  loadingclose,
  gagal,
  checkoutCompleted,
  dashboard,
  datakendaraanfull
}

class DashboardPageState {
  final List<String> suggestions;
  late List<DataKendaraan> namakaryawan;
  final TextEditingController result;
  final TextEditingController checkIn;
  final String? scannedResult;
  final bool isLoading;
  final TextEditingController checkOut;
  final TextEditingController guessName;
  final TextEditingController companY;
  final TextEditingController plateNumber;
  final TextEditingController employeName;
  final TextEditingController permisioN;
  final TextEditingController needfoR;
  final TextEditingController noteS;
  final TextEditingController pathCard;
  final TextEditingController createdAt;
  final bool connected;
  final BluetoothDevice? selectedDevice;
  final List<BluetoothDevice> devices;
  final String? selectedOption;
  final File? image;
  final Map<String, dynamic>? findcode;
  final PageStatus status;
  final TextEditingController plateNumberVar;
  final TextEditingController employeNameVar;
  final TextEditingController companyVar;
  final TextEditingController notesVar;
  final int guessNameCursorPosition;

  DashboardPageState({
    this.suggestions = const [],
    this.namakaryawan = const [],
    TextEditingController? result,
    this.isLoading = false,
    TextEditingController? checkIn,
    this.selectedOption,
    this.image,
    this.scannedResult,
    this.findcode,
    TextEditingController? plateNumberVar,
    TextEditingController? employeNameVar,
    TextEditingController? companyVar,
    TextEditingController? notesVar,
    this.status = PageStatus.idle,
    TextEditingController? checkOut,
    TextEditingController? guessName,
    TextEditingController? companY,
    TextEditingController? plateNumber,
    TextEditingController? employeName,
    TextEditingController? permisioN,
    TextEditingController? needfoR,
    TextEditingController? noteS,
    TextEditingController? pathCard,
    TextEditingController? createdAt,
    List<BluetoothDevice> devices = const [],
    BluetoothDevice? selectedDevice,
    bool connected = false,
    this.guessNameCursorPosition = 0,
  })  : plateNumberVar = plateNumberVar ?? TextEditingController(),
        employeNameVar = employeNameVar ?? TextEditingController(),
        companyVar = companyVar ?? TextEditingController(),
        notesVar = notesVar ?? TextEditingController(),
        result = result ?? TextEditingController(),
        checkIn = checkIn ?? TextEditingController(),
        checkOut = checkOut ?? TextEditingController(),
        guessName = guessName ?? TextEditingController(),
        companY = companY ?? TextEditingController(),
        plateNumber = plateNumber ?? TextEditingController(),
        employeName = employeName ?? TextEditingController(),
        permisioN = permisioN ?? TextEditingController(),
        needfoR = needfoR ?? TextEditingController(),
        noteS = noteS ?? TextEditingController(),
        pathCard = pathCard ?? TextEditingController(),
        createdAt = createdAt ?? TextEditingController(),
        devices = devices,
        selectedDevice = selectedDevice,
        connected = connected;

  DashboardPageState copyWith({
    bool? isLoading,
    PageStatus? status,
    String? selectedOption,
    String? resultText,
    bool? connected,
    String? scannedResult,
    BluetoothDevice? selectedDevice,
    List<BluetoothDevice>? devices,
    List<String>? suggestions,
    List<DataKendaraan>? namakaryawan,
    File? image,
    String? guessNameVar,
    String? checkinVar,
    String? plateNumberVar,
    String? needForVar,
    String? employeNameVar,
    String? companyVar,
    String? notesVar,
    Map<String, dynamic>? findcode,
    int? guessNameCursorPosition,
  }) {
    final TextEditingController updatedResultController =
        TextEditingController.fromValue(
      TextEditingValue(
        text: resultText ?? result.text,
      ),
    );

    return DashboardPageState(
      result: updatedResultController,
      image: image ?? this.image,
      status: status ?? this.status,
      devices: devices ?? this.devices,
      connected: connected ?? this.connected,
      suggestions: suggestions ?? this.suggestions,
      namakaryawan: namakaryawan ?? this.namakaryawan,
      scannedResult: scannedResult ?? this.scannedResult,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      guessName: guessName..text = guessNameVar ?? guessName.text,
      plateNumber: plateNumber..text = plateNumberVar ?? plateNumber.text,
      needfoR: needfoR..text = needForVar ?? needfoR.text,
      employeName: employeName..text = employeNameVar ?? employeName.text,
      companY: companY..text = companyVar ?? companY.text,
      noteS: noteS..text = notesVar ?? noteS.text,
      checkIn: checkIn,
      checkOut: checkOut,
      permisioN: permisioN,
      pathCard: pathCard,
      findcode: findcode ?? this.findcode,
      createdAt: createdAt,
      isLoading: isLoading ?? this.isLoading,
      guessNameCursorPosition:
          guessNameCursorPosition ?? this.guessNameCursorPosition,
    );
  }
}
