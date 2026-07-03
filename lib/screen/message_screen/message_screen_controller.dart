import 'package:get/get.dart';

class MessageScreenController extends GetxController {
  var selectedTab = 0.obs;

  void onLongPress([dynamic item, dynamic context, dynamic index]) {
    // Safe placeholder for conversation long-press actions.
    // Later this can open archive/delete/mute/pin options.
  }
}
