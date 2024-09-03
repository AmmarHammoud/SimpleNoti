import 'package:dio/dio.dart';

class DioHelper {
  ///The static object that is responsible of making requests
  static late Dio dio;

  ///Initialize the helper with the [baseUrl]
  static init({String baseUrl = 'https://simplenotibackend.onrender.com/api/'}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
      ),
    );
  }

  ///A method to send notifications
  static Future<Response> sendNotificationWithKeys({
    required String appKey,
    required String cluster,
    required String appSecret,
    required String appId,
    required String channelName,
    required String message,
    required String title,
    dynamic payload,
    String? roomId,
  }) async {
    var data = {};
    if (roomId == null) {
      data = {
        'channelName': channelName,
        'message': message,
        'title': title,
        'appKey': appKey,
        'appSecret': appSecret,
        'appId': appId,
        'cluster': cluster,
        if(payload != null) 'payload': payload
      };
    } else {
      data = {
        'channelName': channelName,
        'message': message,
        'title': title,
        'roomId': roomId,
        'appKey': appKey,
        'appSecret': appSecret,
        'appId': appId,
        'cluster': cluster,
        if(payload != null) 'payload': payload
      };
    }
    return await dio.post(
      'notiKeys',
      data: data,
      options: Options(
        headers: {'Accept': 'application/json'},
        followRedirects: false,
        validateStatus: (status) {
          return true;
        },
      ),
    );
  }

  static Future<Response> test({dynamic payload}) async {
    return await dio.post(
      'test',
      //data: {'payload': payload},
      options: Options(
        headers: {'Accept': 'application/json'},
        followRedirects: false,
        validateStatus: (status) {
          return true;
        },
      ),
    );
  }
}
