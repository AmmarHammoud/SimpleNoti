import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:simple_noti/simple_noti.dart';

///You need to configure a top level or static method which will handle the action when the notification is pressed.
///Here you handle the action executed when press on a notification action based on the data you pass when you trigger a notification.
@pragma('vm:entry-point')
onTap(e) {
  log('my local notification, details: ${e.payload.toString()}');
  log('action id: ${e.actionId.toString()}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///initialize the client
  ///here where you put your pusher credentials
  await SimpleNotifications.init(
    ///this is an optional parameter.
    ///By default it will just log the data.
    onTap: onTap,

    ///you credentials
    appKey: '96b527d2cb0f549d956c',
    cluster: 'eu',
    appSecret: '0d51a27d63ee3f7c0b4d',
    appId: '1857014',

    ///enable logging to see detailed output of the current situation and event
    ///by default it is set to [true]
    enableLogging: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple noti Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    double spacesBetweenWidget = screenHeight * 0.03;
    return Scaffold(
      appBar: AppBar(
        title: const Text('simple noti'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ValidatedTextField(
              icon: Icons.title,
              controller: titleController,
              hintText: 'title',
            ),
            SizedBox(
              height: spacesBetweenWidget,
            ),
            ValidatedTextField(
              icon: Icons.message,
              controller: bodyController,
              hintText: 'message',
              hasNextText: false,
            ),
            SizedBox(
              height: spacesBetweenWidget,
            ),
            ElevatedButton(
              onPressed: () async {
                ///this is an optional additional payload you may send with the notification data.
                ///It should be a valid json
                Map<String, String> myPayloadJson = {};
                myPayloadJson['some_info'] = 'my payload info';
                myPayloadJson['other_info'] = 'other payload info';

                ///After the initialization you should subscribe to a channel in order to receive events.
                ///Consider changing the place of subscribing in channel to suit your case.
                ///It's put here for illustration purposes.
                ///This would subscribe to `chat.0`
                await SimpleNotifications.subscribe(
                  channelName: 'chat',
                  roomId: 0,
                );

                ///just to ensure that the subscribing has been established.
                ///You probably would NOT need this
                await Future.delayed(const Duration(seconds: 5));

                ///send a notification to the channel named [chat] appended with '0'
                ///i.e. `chat.0`, with title and body provided by the user
                await SimpleNotifications.sendNotifications(
                  channelName: 'chat',
                  roomId: 0,
                  title: titleController.text,
                  message: bodyController.text,
                  payload: myPayloadJson,
                );

                ///The estimated time to make a request
                ///YOU DO NOT NEED THIS IF YOU DO NOT UNSUBSCRIBE IMMEDIATELY
                await Future.delayed(const Duration(seconds: 5));

                ///Do NOT forget to unsubscribe the channel and close the connection after you are done
                await SimpleNotifications.unsubscribeAndClose(
                  channelName: 'chat',
                  roomId: 0,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(screenWidth * 0.3, screenHeight * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'send',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ValidatedTextField extends StatelessWidget {
  final String hintText;
  final bool hasNextText;
  final TextEditingController controller;
  final IconData? icon;
  final double fontSize;
  final double radius;

  const ValidatedTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.hasNextText = true,
      this.icon,
      this.fontSize = 20.0,
      this.radius = 15.0});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction:
          hasNextText ? TextInputAction.next : TextInputAction.done,
      style: TextStyle(
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            radius,
          ),
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
