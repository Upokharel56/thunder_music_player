import 'package:get/get.dart';

class RoutesController extends GetxController {
  var activeLink = 'Songs'.obs;
  final List<String> history = ['Songs']; // Start with the initial tab

  void setActiveLink(String link) {
    if (activeLink.value != link) {
      history.add(link);
      activeLink.value = link;
    }
  }

  bool goBack() {
    if (history.length > 1) {
      history.removeLast(); // Remove the current page
      activeLink.value = history.last; // Go back to the last page in history
      return false; // Prevent app from closing
    }
    return true; // Allow app to close if no more history
  }

  Future<void> popRoute() async {
    goBack();
  }
}
