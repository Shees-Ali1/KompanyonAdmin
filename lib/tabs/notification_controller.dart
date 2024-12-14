import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http ;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth_io.dart';



class NotificationsModel extends GetxController{


  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var _accessToken = ''.obs;



  Future<void> notifications ({required BuildContext context})async{
    try{

      final docs = await _firestore
          .collection("notifications")
          .doc(_auth.currentUser?.uid)
          .collection('notifications').snapshots();

      debugPrint("notifications $docs");

    }catch(error){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }


  Future<void> markAsRead ({required BuildContext context,}) async{

    try{

      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .doc(_auth.currentUser?.uid)
          .collection('notifications')
          .get();

      for (var notificationDoc in notificationsSnapshot.docs) {
        await notificationDoc.reference.update({'read': true});
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Marked as Read Success')));
    }catch(error){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
      debugPrint("markAsRead error $error");

    }


  }


  Future<String> getAccessToken() async {
    final serviceAccount = json.decode('''
  {
  "type": "service_account",
  "project_id": "kompanyonapp-c60f8",
  "private_key_id": "a82c99026fc61c946fbbbd25ee82c0435784d64e",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCubdnS92gTFzhG\\ntZL8chMZYU0Cb0jofGesANpUaCgCTmIxkrFUQVqCbqldysXHOZgRpwyO1/93y1L9\\nnl5MhYq0TB58sPjwmNMkXegF1AqroeHouddR1Th0BDNxBMByqEk69hq9M7DCZCx1\\np/BmoMr8qfdR7xnsZoas3t9dk/4jF34WNBuETRrdV/LQfPYtghZeQByeBJdMwZGb\\nLxfAOzVHLMtXt/CMrpEaQ5WUyDXDmAVRux5c23z+6JFlOdaKGaI0p1xDc7sWxpYz\\nw7OhSL+2dnF/SRh+mdCNhJ9lx/kSegcM9YP4ptYmTYbyTf9JZUqeoJtRBkxMg9Yg\\nudAMIu7jAgMBAAECggEAJz3fe27doy3eI0pGPzUKxvL0+E9A/8y9Jh0rAUJNffdU\\ncAKokmQBkMaEo+0ygZebdp02XgyKFNFRYm12mZCRm+5kDXljB/3Zwpy9zlHd9K7+\\nu/TTVD277Z3kVNDU2vaxQuqLKXWvlowi1HVryCr0f9NdKLm6A00tj0a0ycC5s/r9\\nf2LySVpcWUpm26EQWU1VI05nIB0a5uLhwwVwCR6XoqOXbA95W6/Mh5CfmupFKFcm\\n+eTnQdsFA03tI3GSyciJPve5E1WDJ3yxj8BlbUKSHg3dpDQFlCoUUB94qfFibq16\\nOB8RBQd78DRKHVg5mOkesJskqZkWIdE2vLThl+D7QQKBgQC/dLgDZtG+QB8kmG/s\\nY1jKsBuXkzPOzqcl5LCfTFM/5yupz8UdGl2aJPaGpKCgdyg1rv/DCV4LjDAgAvAt\\nOYX6NLDPPv5+pK+HutX0cGOpsMMy8IqyFstJDtvRYD3Y9F5yWb7hHxqjylcZwGNx\\nMr9JAisvL4sYhtfGXvQoEdPhNQKBgQDpO6kR7cHTc9mnXCrVYb7sGm0fzpjApQjo\\nWJvddgNyyK6WE9gP9CvfoiWfwOUMBCHCSGB+WfqdgoEmxMsC/QmsCWRIwzKWpXy3\\nTWryw9r088gnmj5wQ7KZ7kXAqYywTIDThr3opbpLyLhvY5ptAnXQRTH2ZZVSJEbu\\nChQHC1lqtwKBgC5e1aa1Q32hyCkz5n/JfBrzVmt60qR3NtKdtg2PDea/Vbr2QJaQ\\n6TTJWRA5VVIoKgv+i6GwZh/D33ARZhx9/y4fjudTKY6A0qa8IM/oXKsfzddLnTwO\\n+0OBnsnyVmhyn2FwzSN3Rht/iWMKTst+8Ad9x/nQuQ7CsgYwv0/pKXk1AoGBAKP+\\nOB4MICpPHi5oRxHsfbNDzZD80jk6ka3ViBrKvRf7dY6++0AUfrjrKStQFX1Cdn5G\\nJ9sP54DS337kBp7eTuuxWtsyrSJxz+SPQfDat91egFEgSmDjqPRFLrSOQwc/c6HH\\n70ZjKT/aLZzc2xtlDHPaA4xt1vV/3oPHgFeHqmK3AoGBAKT9Xd9q7ZQ5bG5z+alA\\n5gK/AnQL+KhlsPORWKGnaoOqqS4D4ptq6kvWNwZNhIujtbypNzLj3nNEjfi7RzBf\\nRJjE2slJVsTtOw4O/pOvZSUnKj7sxaifa6nCWeV4L/b5tIljy4CPgz5n4SzcS2f3\\nHk3r+xAUDY0MoMzwldPdrmGw\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk-fhy4i@kompanyonapp-c60f8.iam.gserviceaccount.com",
  "client_id": "108002078339110564682",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fhy4i%40kompanyonapp-c60f8.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''');

    final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccount);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final httpClient = await clientViaServiceAccount(accountCredentials, scopes);
    final accessToken = httpClient.credentials.accessToken.data;
    return accessToken;
  }

  Future<void> sendNotification(String id, String title, String msg) async {
    debugPrint("Function started to send notification");
    try {
        _accessToken.value = await getAccessToken();
      debugPrint("Access Token: $_accessToken.value");

      // Fetch the user's push token from Firestore
      var userDoc = await FirebaseFirestore.instance.collection('userDetails').doc(id).get();

      if (!userDoc.exists) {
        debugPrint('User with ID $id does not exist in users collection');
        return; // Exit function if user document doesn't exist
      }

      var token = userDoc.data()?['fcmToken'];
      if (token == null) {
        debugPrint('User with ID $id does not have a FCM token');
        return; // Exit function if user doesn't have a push token
      }

      // Construct the message
      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': msg,
          },
        },
      };

      // Log the JSON message for debugging
      final jsonMessage = json.encode(message);
      debugPrint('JSON Message: $jsonMessage');

      // Send the notification
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/kompanyonapp-c60f8/messages:send'),
        headers: {
          'Authorization': 'Bearer ${_accessToken.value}',
          'Content-Type': 'application/json',
        },
        body: jsonMessage, // Use the logged JSON message
      );

      // Handle the response
      if (response.statusCode == 200) {
        debugPrint('Message sent successfully to user $id');
      } else {
        debugPrint('Error sending message to user $id: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> sendNotificationtoAll( String title, String msg) async {

      _accessToken.value = await getAccessToken();
    debugPrint("Access Token: ${_accessToken.value}");
    // Get the Firestore instance

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query to get users with the specified role
    final QuerySnapshot usersSnapshot = await firestore
        .collection('userDetails')
        .get();

    // Loop through each user and send a notification
    for (var userDoc in usersSnapshot.docs) {
      // Assuming you have a function to send a notification
      await sendNotification(userDoc.id, title, msg);
    }
  }

  Future<void> makeANotification ({required BuildContext context  ,required String type , required String message,  required String connect_to_role })async{
    try{

      final docRef  = await _firestore
          .collection("notifications")
          .doc(_auth.currentUser?.uid)
          .collection('notifications').add({

        'type': type,
        'read' : false,
        'message' : message,
        'timeStamp': FieldValue.serverTimestamp()
      });

      if(type == "schedule_chat"){
        await _firestore.collection("schedule_notifications").add({
          'type': type,
          'read' : false,
          'message' : message,
          'timeStamp': FieldValue.serverTimestamp(),
          'connect_to_role': connect_to_role,
        });
      }

      await docRef.update({'id': docRef.id});
      debugPrint("Notification created with ID: ${docRef.id}");


    }catch(error){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
      debugPrint("makeANotification error $error");
    }
  }




}