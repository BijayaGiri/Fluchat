import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2/Controller/logincontroller.dart';
import 'package:untitled2/UI/HomeScreen.dart';
import 'package:untitled2/Utils/Utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class  _LoginscreenState extends State<Loginscreen> {
  TextEditingController namecontroller=TextEditingController();
  logincontroller Logincontroller=Get.put(logincontroller());
  TextEditingController username=TextEditingController();
  TextEditingController emailcontroller=TextEditingController();
  TextEditingController password=TextEditingController();
  final _auth=FirebaseAuth.instance;
  FirebaseFirestore _firestore=FirebaseFirestore.instance;//creating the instance of the firebasefirestore

  void signup() {
    _auth.createUserWithEmailAndPassword(
        email: emailcontroller.text.toString(),
        password: password.text.toString()
    ).then((value) async {
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        "uid": _auth.currentUser!.uid.toString(),
        "name": namecontroller.text.toString(),
        "email":emailcontroller.text.toString(),
        "status":"Unavaliable"
      });//this is saying that we
      // are creating a collection named users and inserting a document
      Utils().toastMessage("Signup Successful");
      print("Account Successfully created");

    }).onError((error, stackTrace) {
      Utils().toastMessage(error.toString()); // Handle the error and show a toast
      print(error.toString());
    });
  }

  void login() {
    _auth.signInWithEmailAndPassword(
        email: emailcontroller.text.toString(),
        password: password.text.toString()
    ).then((value) {
      Utils().toastMessage("Login Successful");
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>HomeScreen()));
    }).onError((error, stackTrace) {
      Utils().toastMessage(error.toString()); // Handle the error and show a toast
      print(error.toString());

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
              (){
            bool islogin=Logincontroller.login.value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                islogin?Container(
                  height: MediaQuery.of(context).size.height*0.05,
                  width: MediaQuery.of(context).size.width*0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Login",style: TextStyle(
                          color: Colors.white
                      ),),
                      Text("/"),
                      TextButton(onPressed: (){
                        emailcontroller.clear();
                        password.clear();
                        Logincontroller.removelogin();
                      }, child: Text("Sign Up"))
                    ],
                  ),
                ):Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sign Up"),
                    Text("/"),
                    TextButton(onPressed: (){
                      emailcontroller.clear();
                      password.clear();
                      Logincontroller.setlogin();
                    }, child: Text("Login"))
                  ],
                ),
                islogin?TextFormField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                      hintText: "email"
                  ),
                ):TextFormField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                      hintText: "Name"
                  ),
                ),
                islogin?TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                      hintText: "password"
                  ),
                ):TextFormField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                      hintText: "email"
                  ),
                ),
                if(Logincontroller.login.isFalse)TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                      hintText: "password"
                  ),
                ),
                ElevatedButton(onPressed: (){
                  islogin?login():signup();
                }, child: islogin?Text("login"):Text("Signup")),
              ],
            );
          }
      ),
    );
  }
}

