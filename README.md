# Real-Time Chat Application using Firebase

Chat Application is a Flutter-based mobile app that enables users to send and receive messages in real time. The app uses **Firebase** for authentication and database services, and **SharedPreferences** for local session management.

---

## Features

1. **Signup Page (Create Account)**
   - Users can create an account using email and password.
   - Firebase Authentication handles account creation.

2. **Signin Page (Login Account)**
   - Users can log in using email and password.
   - Login state is saved locally using SharedPreferences.

3. **Forget Password Page**
   - Users can request a password reset email.
   - Firebase sends the reset email to the registered Gmail account.

4. **Home Page**
   - Displays all users.
   - Search functionality to find users by username.
   - Navigate to chat page or chatroom with selected user.

5. **Chat Page**
   - Real-time messaging using Firebase Firestore.
   - Send and receive messages instantly.

6. **Separate Chatroom Page**
   - Each user has a unique chatroom with a particular username.
   - Messages are loaded from Firestore based on chatroom ID.
   - Scrollable list with timestamps for each message.

7. **Text Messaging**
   - Users can send text messages to other users.
   - Messages are stored in Firestore and synced in real-time.

8. **SharedPreferences Integration**
   - Maintains login session locally so users remain logged in even after closing the app.

---

## Getting Started

### Prerequisites

- Flutter >= 3.0.0  
- Dart >= 3.1.0  
- Firebase account  

### Installation

1. **Clone or download the project**
   ```bash
   git clone https://github.com/bhartisahu09/Chat-App
   cd chat_application
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Screenshots


#### Chat_user1
| SignUp Screen | SignIn Screen | Forget Password | Reset Password |
|:---:|:---:|:---:|:---:|
| <img src="images/screenshots/1_signup_screen.png" width="300"> | <img src="images/screenshots/2_sigin_screen.png" width="300"> | <img src="images/screenshots/3_forget_password.png" width="300"> | <img src="images/screenshots/4_reset_pasword.png" width="300"> 

| Home Screen | Search Screen | Search User List | Search User |
|:---:|:---:|:---:|:---:|
| <img src="images/screenshots/5_chat1_user_homescreen.png" width="300"> | <img src="images/screenshots/6_chat1_search.png" width="300"> | <img src="images/screenshots/7_chat1_search_list.png" width="300"> | <img src="images/screenshots/8_chat1_search_user.png" width="300"> |

| Chat1 Send Msg | 
|:---:|
| <img src="images/screenshots/9_chat1_chatroom_send_msg.png" width="300"> | 

#### Chat_user2
| Chat 2 Receive Msg | Chat2 ChatRoom Receive Msg | Chat2 Send Msg to User1 |
|:---:|:---:|:---:|
| <img src="images/screenshots/10_chat1_chatroom2_see_send_msg.png" width="300"> | <img src="images/screenshots/10.1_chat2_chatroom_receive_msg.png" width="300"> | <img src="images/screenshots/11_chat2_chatroom_send_msg.png" width="300"> |

#### Chat_user1
| Chat1 Receive Msg | Chat1 ChatRoom Receive Msg |
|:---:|:---:|
| <img src="images/screenshots/12_chat1_receive_msg_from_chat2.png" width="300"> | <img src="images/screenshots/13_chat1_receive_msg_from_chat2_2.png" width="300"> |

| LogOut App | LogOut PopUp | LogOut and Navigate to login screen |
|:---:|:---:|:---:|
| <img src="images/screenshots/14_logout.png" width="300"> | <img src="images/screenshots/15_logout_popup_show.png" width="300"> | <img src="images/screenshots/16_logout_and_navigate_login_screen.png" width="300"> |
