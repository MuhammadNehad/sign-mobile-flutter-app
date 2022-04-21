import 'dart:convert';

import 'package:dio/dio.dart';

class BaseService {
  static var http = Dio();
  static const baseUri = 'http://62.135.109.243/api/';
  static final Map<String, String> header = {
    'Content-Type': "application/json; charset=UTF-8"
  };
  static Future<Response> makeRequest(String url,
      {String method = 'POST',
      bodyd,
      mergeDefaultHeader = true,
      Map<String, String> extraHeaders,
      bool fromForm = false}) async {
    try {
      extraHeaders ??= {};
      var sentHeaders = header;
      if (extraHeaders.entries.length > 0) {
        sentHeaders.addAll(extraHeaders);
      }

      switch (method) {
        case 'POST':
          bodyd ??= {};
          return await Dio().post(Uri.parse(url).toString(),
              options: Options(headers: sentHeaders),
              data: !fromForm ? jsonEncode(bodyd) : bodyd);
        case 'GET':
          bodyd ??= {};
          return await Dio().get(
            Uri.parse(url).toString(),
            options: Options(headers: sentHeaders),
          );
        case 'PUT':
          bodyd ??= {};
          return await Dio().put(
            Uri.parse(url).toString(),
            data: bodyd,
            options: Options(headers: sentHeaders),
          );
        case 'DELETE':
          bodyd ??= {};
          return await Dio().delete(
            Uri.parse(url).toString(),
            options: Options(headers: sentHeaders),
          );
        default:
          return await Dio().post(Uri.parse(url).toString(),
              options: Options(headers: sentHeaders), data: jsonEncode(bodyd));
      }
    } catch (e) {
      return Response(
          statusMessage: "error", statusCode: 400, requestOptions: null);
    }
  }

  static void test() async {
    await makeRequest("https://jsonplaceholder.typicode.com/posts", bodyd: {
      "title": "beatae soluta recusandae",
      "body":
          "dolorem quibusdam ducimus consequuntur dicta aut quo laboriosam\nvoluptatem quis enim recusandae ut sed sunt\nnostrum est odit totam\nsit error sed sunt eveniet provident qui nulla"
    });
  }
}
