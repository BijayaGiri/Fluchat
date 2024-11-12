import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
class Chatroom extends StatefulWidget {
  final String user;
  final Map<String, dynamic>? userMap;
  final String chatID;
  const Chatroom({super.key, required this.user, required this.chatID, required this.userMap});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  File? imageFile;
  final auth = FirebaseAuth.instance;
  bool iconvalidity = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _message = TextEditingController();
  ScrollController _scrollController = ScrollController(); // Added ScrollController
// ****************************************************************
 //This function is to pick the image
  Future getImage()async{
  ImagePicker _picker=ImagePicker();
  await _picker.pickImage(source: ImageSource.gallery).then((xFile){
    //this will return the image in the format of XFile
    if(xFile!=null){
      imageFile=File(xFile.path);
    }
  }); //picking the image from the gallery


  }
  Future uploadImage() async{
    //to generate the unique string. as the images with the same name override each other.
    String filename=Uuid().v1();
    var ref=FirebaseStorage.instance.ref().child('images').child(""); //creating the reference and the path for the Firebase image storage
   var upload=await ref.putFile(imageFile!);//as this returns future we need to put await
    String ImageUrl=await upload.ref.getDownloadURL(); //this creates the download link of the image that is put in the firebase
    
  }

  //***************************************************************
  // Function to send chat
  void chatsend() async {
    if (_message.text.toString().isNotEmpty) {
      Map<String, dynamic> message = {
        "sendby": auth.currentUser!.email.toString(),
        "message": _message.text.toString(),
        "time": FieldValue.serverTimestamp(),
      };
      _message.clear();
      await firestore.collection("chatroom").doc(widget.chatID).collection("chats").add(message);
      setState(() {
        iconvalidity = false;
      });
      scrollToBottom(); // Scroll to bottom when message is sent
    }
  }

  // Function to scroll to bottom
  void scrollToBottom() {
    if (_scrollController.hasClients) {//this part checks if the scrollbottom is a part of scrollable widget
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(microseconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when chatroom opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: firestore.collection("Users").doc(widget.userMap!["uid"]).snapshots(),
          builder: (context, snapshots) {
            if (snapshots.data != null) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    snapshots.data!["name"].toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  snapshots.data!["status"].toString() == "online"
                      ? Icon(Icons.circle, color: Colors.green)
                      : Icon(Icons.circle, color: Colors.grey),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("chatroom")
                    .doc(widget.chatID)
                    .collection("chats")
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scrollToBottom(); // Scroll to bottom when new messages arrive
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return messages(map);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType:TextInputType.multiline,
                    maxLines: null,
                    onChanged: (text) {
                      setState(() {
                        iconvalidity = text.isNotEmpty;
                      });
                    },
                    controller: _message,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.perm_media_outlined)),
                      hintText: "Send Message",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: iconvalidity ? chatsend : null,
                  icon: Icon(Icons.send, color: iconvalidity ? Colors.blue : Colors.blue.shade200),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Message bubble widget
  Widget messages(Map<String, dynamic> map) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: map["sendby"] == auth.currentUser!.email ? Alignment.centerRight : Alignment.centerLeft,
      child: map["sendby"] == auth.currentUser!.email
          ? Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blue,
        ),
        child: Text(
          map["message"],
          style: TextStyle(color: Colors.white),
        ),
      )
          : Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade200,
        ),
        child: Text(map["message"]),
      ),
    );
  }
}
