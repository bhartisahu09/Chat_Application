import 'package:chatapp/pages/home.dart';
import 'package:chatapp/service/database.dart';
import 'package:chatapp/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String profileurl;
  final String username;

  ChatPage({
    required this.name,
    required this.profileurl,
    required this.username,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  bool loading = true;
  final SharedPreferenceHelper sharedPrefHelper = SharedPreferenceHelper();
  Stream? messageStream;

  /// Fetch shared preferences data and initialize chat room
  Future<void> getSharedPref() async {
    try {
      myUserName = await sharedPrefHelper.getUserName();
      myProfilePic = await sharedPrefHelper.getUserPic();
      myName = await sharedPrefHelper.getUserDisplayName();
      myEmail = await sharedPrefHelper.getUserEmail();
      chatRoomId = getChatRoomIdByUsername(  myUserName!, widget.username);
 print("chatRoomId in ChatPage ${chatRoomId}");
      print("Shared Preferences Loaded:");
      print("Username: $myUserName");
      print("Profile Pic: $myProfilePic");
      print("Name: $myName");
      print("Email: $myEmail");
      print("Chat Room ID: $chatRoomId");
      //  getAndSetMessages(chatRoomId!);
    } catch (e) {
      print("Error loading shared preferences: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

   String getChatRoomIdByUsername(String a, String b) {
    print("data convert chat:   ${a} ${b}");
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

getAndSetMessages() async {

  messageStream = DatabaseMethods().getChatRoomMessages(chatRoomId!);
  print("Message Stream Initialized: $messageStream"); 

  setState(() {});
}

 Widget chatMessage() {
  return StreamBuilder(
    stream: messageStream, 
    builder: (context, AsyncSnapshot snapshot) {

          print("snapshot chat data: ${snapshot}");
      print("Snapshot Data: ${snapshot.data}");
      print("Snapshot Error: ${snapshot.error}");
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        print("Error: ${snapshot.error}"); 
        return Center(child: Text("Error: ${snapshot.error}"));
      }

      // If there are no messages
      if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
        return Center(child: Text("No messages yet"));
      }

      // If there are messages, display them
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 90.0, top: 130),
        itemCount: snapshot.data.docs.length,
        reverse: true, 
        itemBuilder: (context, index) {
          DocumentSnapshot ds = snapshot.data.docs[index];
          
          // Debugging: Print the data for each message
          print("Message Data: ${ds['message']}"); 

          return chatMessageTile(ds["message"], myUserName == ds["sendBy"]);
        },
      );
    },
  );
}



  /// Display each chat message
  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomRight: sendByMe ? Radius.circular(0) : Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: sendByMe ? Radius.circular(24) : Radius.circular(0)),
                color: sendByMe
                    ? Color.fromARGB(255, 234, 236, 240)
                    : Color.fromARGB(255, 211, 228, 243)),
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }

  /// Add a new message to Firestore
  void addMessage(bool sendClicked) {
    if (messageController.text.isNotEmpty) {
      String message = messageController.text;
      messageController.clear();

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myProfilePic,
      };

      messageId ??= randomAlphaNumeric(10);

      // Add the message to Firestore
      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((_) {
        print("Message added successfully!");

        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "lastMessageSendBy": myUserName,
        };
        DatabaseMethods()
        .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      }).catchError((e) {
        print("Error adding message: $e");
      });
    }
  }

  onload ()async{
    await getSharedPref();
    await getAndSetMessages();
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    onload();
   
   
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Color(0xFF553370),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xffc199cd),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: Container(
        margin: EdgeInsets.only(top: 60.0),
        child: Stack(
          children: [
            // Chat body section
            Container(
              margin: EdgeInsets.only(top: 50.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.12,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: chatMessage(),
            ),
           
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => Home()));
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Color(0xffc199cd),
                    ),
                  ),
                  SizedBox(width: 90.0),
                  Text(
                    widget.name,
                    style: TextStyle(
                      color: Color(0xffc199cd),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type a message",
                              hintStyle: TextStyle(color: Colors.black45),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            addMessage(true);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFf3f3f3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.send,
                                color: Color.fromARGB(255, 166, 159, 159),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
