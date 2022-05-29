import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_flutterapp/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutterapp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'c';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  TextEditingController textController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool getVisibility = false;

  late String messageText;

  void getCurrentUser() {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  /*void getMessages() async {
    final messagesCollection = await _fireStore.collection('messages').get();
    for (var messages in messagesCollection.docs) {
      print(messages.data());
    }
  }

  void streamMessages() async {
    await for (var snapshots in _fireStore.collection('messages').snapshots()) {
      for (var messages in snapshots.docs) {
        print(messages.data());
      }
    }
  }*/

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  String getCurrentTime(_now) {
    String year = _now.year.toString();
    String month = _now.month.toString();
    String day = _now.day.toString();
    String hour = _now.hour.toString();
    String minute = _now.minute.toString();
    String second = _now.second.toString();
    if (month.length < 2) {
      month = '0$month';
    }
    if (day.length < 2) {
      day = '0$day';
    }
    if (hour.length < 2) {
      hour = '0$hour';
    }
    if (minute.length < 2) {
      minute = '0$minute';
    }
    if (second.length < 2) {
      second = '0$second';
    }
    return '$year:$month:$day:$hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MessageStream(fireStore: _fireStore),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        setState(() {
                          if (value.length > 0) {
                            getVisibility = true;
                          } else {
                            getVisibility = false;
                          }
                        });
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  Visibility(
                    visible: getVisibility,
                    child: TextButton(
                      onPressed: () {
                        DateTime _now = DateTime.now();
                        textController.clear();
                        _fireStore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser?.email,
                          'time': getCurrentTime(_now),
                        });
                        setState(() {
                          getVisibility = false;
                        });
                      },
                      child: Icon(
                        Icons.send,
                        size: 40,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({
    Key? key,
    required FirebaseFirestore fireStore,
  })  : _fireStore = fireStore,
        super(key: key);

  final FirebaseFirestore _fireStore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _fireStore
          .collection('messages')
          .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        List<Widget> mList = [];
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
        final messages = snapshot.data?.docs.reversed;
        for (var message in messages!) {
          final messageText = message.data()['text'];
          final messageSender = message.data()['sender'];
          final messageTime = message.data()['time'];
          final currentUser = loggedInUser?.email;
          mList.add(
            MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender,
              time: messageTime,
            ),
          );
        }
        return Expanded(
          child: ListView(
            reverse: true,
            scrollDirection: Axis.vertical,
            children: mList,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {Key? key,
      required this.text,
      required this.sender,
      required this.isMe,
      required this.time})
      : super(key: key);

  final String text;
  final String sender;
  final String time;
  final bool isMe;

  String getTime(time) {
    String currentTime = time;
    List timeList = currentTime.split(':');
    String newTime = '${timeList[3]}:${timeList[4]}';
    return newTime;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Material(
            elevation: 5,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Material(
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                getTime(time),
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
