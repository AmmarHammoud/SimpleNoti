<!-- ## 📚️ Docs

1. [Documentation](/docs/)
2. [Youtube](https://youtube.com/)
3. [Telegram Support Group](https://t.me/)
4. [Contact Developer](https://github.com/AmmarHammoud) (check social media or readme profile github)  
## 🔖️ Features  
1. [x] 📱️ **Cross Platform** support (Mobile, and Web)
2. [x] ✨️ **Easy-to-use** (user friendly for newbie)   -->
<!-- ## 🔖️ Todo  
1. [ ] 📱️ **Cross Platform** support (Mobile, and Web)
2. [ ] 📜️ **Standarization** Style Code
3. [ ] ✨️ **Pretty Information** (user friendly for newbie) -->
### 📚️ Introduction:  
Imagine that you are bored at home, so you decide to watch the TV, you turn it on, and a channel `X` appears.  
<img src="https://media.giphy.com/media/MuJDYvbYKzMwONKvdO/giphy.gif?cid=790b76111q66noex6riw60nvnf6aeakl3ahzyh5ivy4ygpnm&ep=v1_gifs_search&rid=giphy.gif&ct=g" width="300" align="right"/>
You watch it for a moment then you decide that you want something funnier, so you change the channel. When you are watching a channel, you are listening to every sound, and observing every event that is being broadcasted on it. On the other hand, when you change the channel, you stop listening and observing.  
Now, in other words, let's say that whenever you start watching (_or listening to_) a channel, you _subscribe_ to it, and whenever you change the channel, you _unsubscribe_ from the previous one, and start _listening_ to the new one.  
Moreover, whenever you turn off the TV, you _unsubscribe_ from every _channel_. Additionally, perhabs in some TVs you may divide the screen into mutliple parts, and start _listening_ to all of them at the same time.  
### 💡 Understanding Pusher  
Well, in terms of Pusher (or sending notifications in general), there is no difference to what we have just explored. You may create a _channel_ where some users _subscribe_ to it and strat _listening_ to every _event_ being _broadcasted_.  
  
You may create several _channels_. And every _listener_ may _listen_ to mutliple _channels_ at the same time.  
  
### 📝 Example  
"But programmatically speaking, how may we differentiate between these stuff?" you may ask. In order to elaborate more on this, let's see the following example:  
>Assume that we want to create a chat app like Whatsapp, where every user may chat with several users and recieve messages in real time. And a notification should be sent to him whenever someone messages him.  

__Try to take a moment and think how you would implement this.__  
  
Consider the following approach:  
  
We have an important note that every chat has its `id`, let's call it: `chatId`.  
  
So, let's say that every time our user (let's call him `u`) enters a chat, we create a _channel_ called: `chat.${chatId}` for example, and force the sender and the reciever to _subscribe_ to that _channel_, so that whenever the sender sends a message, it will be _broadcasted_ to this _channel_, and as the reciever is _listening_ to this _channel_, he will be notified that a message has arrived.  
  
Yet, we have a small problem here, which is that whenever an event is _triggered_ (broadcasted) into this _channel_, every _subscriber_ will be notified including the sender. So, how may we solve this?  
  
We know that every user has a unique `id`, so we may take advantage of this note.  
A simple approach is to check whether the `sender.id == u.id` (in other words, we are checking whether the sender is ourself or not), if so, then we may drop the _event_. Otherwise, we do want to keep the _event's data_.  
Kindly, refer to the example code in order to have further understanding.  
  
### 🔔 Now, let's move on to notifications part  
A simple approach that we create a _channel_ called: `global.${u.id}` (in other words, we are creating a channel for ourselves), and _subscribe_ to it, and whenever another user sends a message we will _trigger_ an _event_ with destination _channel_ `global.${reciever.id}`.  
  
So, we will recieve a message (in terms of real time) as we are _listening_ to `chat.${chatId}`, and a notification as we are _listening_ to `global.${u.id}`.  
___  
# Usage  

### 💻 Implementation:  
Now, let's go through what we have explored so far.  
Firstly, we should create an account on [Puhser.com](https://pusher.com), where we will be provided with: `key`, `app_id`, `secret`, and `cluster`.  
The `SimpleNoti` class is a singleton, that can be instantiated with `init()`. Then you need to initialize it with a number of configuration options, here is a quick example with a number of callbacks options:  
```
  await SimpleNotifications.init(
    onTap: onTap,
    appKey: YOUR_KEY,
    cluster: YOUR_CLUSTER,
    appSecret: YOUR_SECRET,
    appId: YOUR_APP_ID,
    enableLogging: true,
  );
```
`onTap` method is where you handle the action executed when press on a notification, it's an optional method, and it logs the notification's details by default.  
`enableLogging` is a flag that decides whether you want to include the log messages in your terminal or not, it provides useful messages that help you knowing the current state of your app.  
#### 〰️ Subscribtion  
After that, you should subscribe to a channel in order to start listening to the events  
```
await SimpleNotifications.subscribe(
        channelName: 'chat',
        roomId: 0,
    );
```  
the `roomId` is an optional paramter, if it is not provided, the subscribtion would be established to `channelName` (`chat` in this case), otherwise, it would be established to `channelName.roomId` (`chat.0` in this case).  
You may override `onEvent` method in `SimpleNotifications.subscribe()`, by default it displays a notification on the screen whenever an event is recieved.  
#### 📨 Send a remote notification  
You may send a notification using:  
```
await SimpleNotifications.sendNotifications(
        channelName: 'chat',
        roomId: 0,
        title: 'some title',
        message: 'your body message',
        payload: yourPayloadJson,
    );
```  
where `title` is the title of the notification that is going to be sent, `message` is the the message that is going to be included in the body of the notification, and `payload` is additional paramter if you want to include a specific data in the event that is going to be triggered.  
#### 📩 Send a local notification  
You may also send a local notification using
```
await SimpleNotifications.showNotifications(
        title: 'some title',
        message: 'your body message',
    );   
```  
#### 🚫 Unsubscribtion and closing the connection  
After you have finished with the channel, do not forget to unsubcribe and close the connection in order to free the resources  
```
await SimpleNotifications.unsubscribeAndClose(
        channelName: 'chat',
        roomId: 0,
    );
```
