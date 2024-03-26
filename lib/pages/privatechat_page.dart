import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:okeys/colors.dart';
import 'package:okeys/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class PrivateChatPage extends StatefulWidget {
  final String userId;
  final String agentId;
  final String visiteId;

  const PrivateChatPage({
    Key? key,
    required this.userId,
    required this.agentId,
    required this.visiteId,
  }) : super(key: key);

  @override
  _PrivateChatPageState createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          title: Text(
            'Private Chat',
            style: TextStyle(color: Palette.primary),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: MessagesList(
                userId: widget.userId,
                agentId: widget.agentId,
                visiteId: widget.visiteId,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Palette.primary),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Palette.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.primary),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        fillColor: Palette.background,
                        filled: true,
                        hintText: 'Enter your message...',
                        hintStyle: TextStyle(color: Palette.text),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Palette.primary,
                    onPressed: () {
                      _sendMessage(widget.userId, widget.agentId,widget.visiteId);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

 void _sendMessage(String senderId, String receiverId,String visiteId) {
  final messageText = _messageController.text.trim();
  print('visiteId avant d\'envoyer le message : $visiteId'); // Ajout du print
  if (messageText.isNotEmpty) {
    FirebaseFirestore.instance.collection('messages').add({
      'sender_id': senderId,
      'receiver_id': receiverId, // Utilisez l'identifiant du destinataire ici
      'message': messageText,
      'visite_id': visiteId,
      'timestamp': DateTime.now(),
    });
    _messageController.clear();
  }
}


}

class MessagesList extends StatelessWidget {
  final String userId;
  final String agentId;
  final String visiteId;

  const MessagesList({
    Key? key,
    required this.userId,
    required this.agentId,
    required this.visiteId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('visite_id', isEqualTo: visiteId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet'));
        } else {
          final messages = snapshot.data!.docs;
          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSender = message['sender_id'] == userId;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: isSender
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSender ? Palette.primary : Palette.background,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            color: isSender ? Palette.background : Palette.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
