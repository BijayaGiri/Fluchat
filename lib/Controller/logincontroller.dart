import 'package:get/get.dart';

class logincontroller extends GetxController{
  RxBool login=true.obs;
  void setlogin(){
    login.value=true;
  }
  void removelogin(){
    login.value=false;
  }
}