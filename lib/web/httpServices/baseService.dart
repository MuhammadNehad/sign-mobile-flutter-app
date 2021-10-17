import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BaseService {
  static const baseUri = 'http://192.168.1.9:5421/api/';
  static final Map<String, String> header = {
    'Content-Type': "application/json; charset=UTF-8"
  };
  static Future<http.Response> makeRequest(String url,
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
          return await http.post(Uri.parse(url),
              headers: sentHeaders, body: jsonEncode(bodyd));
        case 'GET':
          bodyd ??= {};
          return await http.get(Uri.parse(url), headers: sentHeaders);
        case 'PUT':
          bodyd ??= {};
          return await http.put(Uri.parse(url), headers: sentHeaders);
        case 'DELETE':
          bodyd ??= {};
          return await http.delete(Uri.parse(url), headers: sentHeaders);
        default:
          return await http.post(Uri.parse(url),
              headers: sentHeaders, body: bodyd);
      }
    } catch (e) {
      return http.Response("error", 400);
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
