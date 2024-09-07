import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

class SidebarController extends GetxController{
  RxInt selectedindex =0.obs;
  RxBool showsidebar =false.obs;
  final controller = SidebarXController(selectedIndex: 0, extended: true);

}