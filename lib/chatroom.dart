import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Chatroom extends StatefulWidget {
  final String user;
  final Map<String,dynamic>? userMap;
  final String chatID;
  const Chatroom({super.key,required this.user,required this.chatID,required this.userMap});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {

  final auth = FirebaseAuth.instance;
  bool iconvalidity=false;
  FirebaseFirestore firestore=FirebaseFirestore.instance;//initializing the firebase
  TextEditingController _message=TextEditingController();
  void chatsend()async{
    //creating a map to add in the collection
    if(_message.text.toString().isNotEmpty){
      Map<String,dynamic> message={
        "sendby":auth.currentUser!.email.toString(),
        "message":_message.text.toString(),
        "time":FieldValue.serverTimestamp(),//helps to store the current time

      };
_message.clear();
      //adding the chat
      //inside chatroom then inside the chatid then inside the chats
      await firestore.collection("chatroom").doc(widget.chatID).collection("chats").add(message);
setState(() {
  iconvalidity=false;
});
    }
  }
  @override
  Widget build(BuildContext context) {
print(_message);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userMap!["name"],style: TextStyle(
            color: Colors.white
        ),),
      ),
      body:
      Column(
        children: [
          Expanded(
            child: Container(
              child:StreamBuilder<QuerySnapshot>(
                stream: firestore.collection("chatroom").doc(widget.chatID).collection("chats").orderBy("time",descending: false).snapshots(),
                builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context,index){
                          Map<String,dynamic> map=snapshot.data!.docs[index].data() as Map<String,dynamic>;
                          return messages(map);
                        });
                  }else{
                    return Container(

                    );
                  }

                },
              ) ,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (text){
                      setState(() {
                        iconvalidity=text.isNotEmpty;
                      });
                    },
                    controller: _message,
                    decoration: InputDecoration(
                        hintText: "Send Message",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                  ),
                ),
                IconButton(onPressed:
                  iconvalidity?chatsend:null,
                icon: Icon(Icons.send,color: iconvalidity?Colors.blue:Colors.blue.shade200,))
              ],
            ),
          )

        ],
      ),

    );

  }
  Widget messages(Map<String,dynamic>map){
   return Container(
     width:MediaQuery.of(context).size.width,
    alignment: map["sendby"]==auth.currentUser!.email?Alignment.centerRight:Alignment.centerLeft,
     child: Container(
       margin: EdgeInsets.all(10),
       padding: EdgeInsets.all(10),
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(20),
         color: Colors.blue
       ),
       child: Text(map["message"],style: TextStyle(color: Colors.white),),
     ),
    );

  }
}