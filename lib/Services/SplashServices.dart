import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/UI/HomeScreen.dart';
import 'package:untitled2/UI/LoginScreen.dart';
class SplashServices {
  void isLogin(BuildContext context) {
    final auth=FirebaseAuth.instance;//this will help us get the instance of the authentication
    final user=auth.currentUser;//this will give all te data of the current user if he / she is logged in
    if(user!=null){ //checks if the user already exists or not if it exits it will return a valid data
      //if not a valid data it will return null which will be checked here
      Timer(
        //if user exits and user is a valid data then we have to move on the post screen
          Duration(seconds: 3),
              () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen())));

    }
    else{
      //if user is not registered then the page must go into the login screen
      Timer(
          Duration(seconds: 3),
              () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) =>Loginscreen())));
    }
  }
}