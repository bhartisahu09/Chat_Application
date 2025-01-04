import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/service/shared_pref.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds user details to the database
  Future<void> addUserDetails(
      Map<String, dynamic> userInfoMap, String id) async {
    return await _firestore.collection("users").doc(id).set(userInfoMap);
  }

  /// Retrieves a user by email
  Future<QuerySnapshot> getUserByEmail(String email) async {
    return await _firestore
        .collection("users")
        .where("E-mail", isEqualTo: email)
        .get();
  }

  /// Searches for users by username
  Future<QuerySnapshot> searchUsers(String username) async {
    return await _firestore
        .collection("users")
        .where("SearchKey", isEqualTo: username.substring(0, 1).toUpperCase())
        .get();
  }

 Future<void> createChatRoom(
  String chatRoomId,
  Map<String, dynamic> chatRoomInfoMap,
) async {
  try {
    final snapshot = await _firestore.collection("messageRoom").doc(chatRoomId).get();

    print("chatRoomId data create: $chatRoomId");
    print("chatRoomInfoMap: $chatRoomInfoMap");

    if (snapshot.exists) {
      // If the chat room exists, update the document
      print("Chat room exists, updating...");
      await _firestore
          .collection("messageRoom")
          .doc(chatRoomId)
          .update(chatRoomInfoMap);
    } else {
      // If the chat room does not exist, create it
      print("Chat room does not exist, creating...");
      await _firestore
          .collection("messageRoom")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  } catch (e) {
    print("Error creating/updating chat room: $e");
  }
}

Future<void> addMessage(
  String chatRoomId, 
  String messageId, 
  Map<String, dynamic> messageInfoMap
) async {
   print("data aaya: messageInfoMap ${messageInfoMap} messageId ${messageId} chatRoomId ${chatRoomId} ");
  try {
    // Firestore reference    
    await FirebaseFirestore.instance
        .collection("messageRoom") // Main collection
        .doc(chatRoomId)           // Chat room document
        .collection("messages")    // Nested collection for messages
        .doc(messageId)            // Specific message document
        .set(messageInfoMap);      // Message data

    print("Message added successfully to chat room: $chatRoomId");
  } catch (e) {
    print("Error adding message: $e");
  }
}

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) async {
    try {
      // Check if the document exists
      DocumentSnapshot docSnapshot =
          await _firestore.collection("messageRoom").doc(chatRoomId).get();

      if (docSnapshot.exists) {
        // Document exists, update it
        await _firestore
            .collection("messageRoom")
            .doc(chatRoomId)
            .update(lastMessageInfoMap);
        print("Last message updated successfully.");
      } else {
        // Document doesn't exist, create it with the last message info
        await _firestore
            .collection("messageRoom")
            .doc(chatRoomId)
            .set(lastMessageInfoMap);
        print("New message room created and last message set.");
      }
    } catch (e) {
      print("Error updating or creating message room: $e");
    }
  }

  Stream<QuerySnapshot> getChatRoomMessages(String chatRoomId) {
    return _firestore
        .collection("messageRoom")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUserName = await SharedPreferenceHelper().getUserName();
    if (myUserName == null) {
      throw Exception("UserName not found in shared preferences.");
    }
    print("myUserName: ${myUserName}");

    final querySnapshot = await _firestore
        .collection("messageRoom")
        .orderBy("time", descending: true)
        .where("users", arrayContains: myUserName)
        .get();

    print("Query Snapshot: ${querySnapshot.docs.length} documents found");
    return _firestore
        .collection("messageRoom")
        .orderBy("time", descending: true)
        .where("users", arrayContains: myUserName)
        .snapshots();
  }
}