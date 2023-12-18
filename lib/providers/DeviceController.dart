// ignore_for_file: file_names

import 'package:get/get.dart';

class DeviceController extends GetxController {
  RxString selectedDeviceId = "".obs;

  void setSelectedDeviceId(String deviceId) {
    selectedDeviceId.value = deviceId;
  }
}
