import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class BaseService {
  var http = Dio();
  static const baseUri = 'http://62.135.109.243:3232/api/';
  static final Map<String, String> header = {
    'Content-Type': "application/json; charset=UTF-8"
  };
  static Future<Response> makeRequest(String url,
      {String method = 'POST',
      bodyd,
      mergeDefaultHeader = true,
      Map<String, String> extraHeaders}) async {
    try {
      extraHeaders ??= {};
      var sentHeaders = header;
      switch (method) {
        case 'POST':
          bodyd ??= {};
          return await Dio().post(Uri.parse(url).toString(),
              options: Options(headers: sentHeaders), data: jsonEncode(bodyd));
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

  static Future<String> apiRequest(String url, Map jsonMap,
      {String methods: "POST"}) async {
    HttpClient httpClient = new HttpClient();

    switch (methods) {
      case 'POST':
        HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
        request.headers.set('content-type', 'application/json');
        request.add(utf8.encode(jsonEncode(jsonMap)));
        HttpClientResponse response = await request.close();
        String reply = await response.transform(utf8.decoder).join();
        String scode = response.statusCode.toString();
        httpClient.close();
        return scode;
      case 'GET':
        HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
        request.headers.set('content-type', 'application/json');
        HttpClientResponse response = await request.close();
        String reply = await response.transform(utf8.decoder).join();
        String scode = response.statusCode.toString();
        httpClient.close();
        return reply;
      default:
        HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
        request.headers.set('content-type', 'application/json');
        HttpClientResponse response = await request.close();
        String reply = await response.transform(utf8.decoder).join();
        String scode = response.statusCode.toString();
        httpClient.close();
        return reply;
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
