import 'package:chatapp/pages/chatpage.dart';
import 'package:chatapp/pages/signin.dart';
import 'package:chatapp/service/database.dart';
import 'package:chatapp/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myName, myProfilePic, myUserName, myEmail;
  Stream? chatRoomStream;

  getSharedPref() async {
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    print("userData: ${myName}");
    setState(() {});
  }

  Future<void> ontheload() async {
    await getSharedPref();
    if (mounted) {
      chatRoomStream = await DatabaseMethods().getChatRooms();
      print("chatRoomStream: ${chatRoomStream}");
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        print("Snapshot Connection State: ${snapshot.connectionState}");
        print("Snapshot Data: ${snapshot.data?.docs}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData ||
            snapshot.data?.docs == null ||
            snapshot.data?.docs.isEmpty) {
          return Center(child: Text("No messages yet"));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            print(
                "Chat Room Data: ${ds.data()}"); // Log the chat room data for debugging
            return ChatRoomListTile(
              chatRoomId: ds.id,
              lastMessaage: ds["lastMessage"] ?? "",
              myUserName: myUserName!,
              time: ds["lastMessageSendTs"],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  String getChatRoomIdByUsername(String b, String a) {
    print("data convert home:   ${a} ${b}");
    // return "$b\_$a";
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  // Search variables
  var queryResultSet = [];
  var tempSearchStore = [];

  void initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().searchUsers(value).then((QuerySnapshot docs) {
        for (var doc in docs.docs) {
          queryResultSet.add(doc.data());
        }
      });
    } else {
      tempSearchStore = [];
      for (var element in queryResultSet) {
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      }
    }
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});

        var chatRoomId = getChatRoomIdByUsername(myUserName!, data["username"]);
        print("chatRoomId in homePage ${chatRoomId}");
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, data["username"]],
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: data["Name"],
              profileurl: data["Photo"],
              username: data["username"],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    data["Photo"],
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["Name"],
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      data["username"],
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: Container(
        child: Column(
          children: [
            SizedBox(width: 50.0),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Logout"),
                        content:
                            const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF553370),
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const SignIn(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text(
                              "Yes",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3a2144),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Color(0xffc199cd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search
                      ? Expanded(
                          child: TextField(
                          onChanged: (value) {
                            initiateSearch(value.toUpperCase());
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search User',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ))
                      : Container(
                          child: Column(
                            children: [
                              Text(
                                "ChatUp ",
                                style: TextStyle(
                                  color: Color(0xffc199cd),
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                " ${myName}",
                                style: TextStyle(
                                  color: Color(0xffc199cd),
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                  GestureDetector(
                    onTap: () {
                      search = !search;
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFF3a2144),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        search ? Icons.close : Icons.search,
                        color: Color(0xffc199cd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: search
                    ? ListView(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        primary: false,
                        shrinkWrap: true,
                        children: tempSearchStore.map((element) {
                          return buildResultCard(element);
                        }).toList(),
                      )
                    : ChatRoomList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessaage, chatRoomId, myUserName, time;
  ChatRoomListTile({
    required this.chatRoomId,
    required this.lastMessaage,
    required this.myUserName,
    required this.time,
  });

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUserName, "");
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Photo"]}";
    id = " ${querySnapshot.docs[0]["Id"]}";
    print("my name ${name}");
    setState(() {});
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {});

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: name,
              profileurl: profilePicUrl,
              username: username,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicUrl.isEmpty
                ? CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      profilePicUrl,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
            SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Text(
                  username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.6,
                  child: Text(
                    widget.lastMessaage,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              widget.time,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
