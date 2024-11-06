import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/UI/LoginScreen.dart';
import 'package:untitled2/Utils/Utilities.dart';
import 'package:untitled2/chatroom.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  String chatID(String user1, String user2) {
    // Sort the user IDs alphabetically to ensure a unique and consistent Chat ID
    if (user1.compareTo(user2) > 0) {
      return "$user2$user1";
    } else {
      return "$user1$user2";
    }
  }
  Map<String, dynamic> userMap = {}; // Initialized as an empty map
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection("Users")
          .where("email", isEqualTo: searchController.text.trim())
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userMap = snapshot.docs[0].data();
        });
        print(userMap);
      } else {
        Utils().toastMessage("No user found");
      }
    } catch (error) {
      Utils().toastMessage("An error occurred: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HomeScreen",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(onPressed: (){
            _auth.signOut().then((value){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
            });
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(strokeWidth: 3.0),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onSearch,
              child: const Text("Search"),
            ),
            if (userMap.isNotEmpty)
              ListTile(
                onTap: () {
                  debugPrint("ListTile tapped!");
                  String roomID = chatID(
                    _auth.currentUser!.uid.toString(),
                    userMap["uid"],
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chatroom(
                        chatID: roomID,
                        user: userMap["name"],
                        userMap: userMap,
                      ),
                    ),
                  );
                },
                title: Text(userMap["name"]),
                subtitle: Text(userMap["email"]),
                trailing: Icon(Icons.chat),
              ),
          ],
        ),
      ),
    );
  }
}
