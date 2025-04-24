import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import "dart:collection";

class QualityLinks {
  String? videoId;
  String? accessToken;

  QualityLinks(this.videoId, this.accessToken);

  Future<SplayTreeMap?> getQualitiesSync() {
    return getQualitiesAsync();
  }

  Future<SplayTreeMap?> getQualitiesAsync() async {
    try {
      final Uri? vimeoLink =
          Uri.tryParse('https://api.vimeo.com/videos/$videoId');

      var response = await http.get(
        vimeoLink!,
        headers: {
          "Accept": "application/vnd.vimeo.*+json;version=3.4",
          if (accessToken != null) ...{
            "Authorization": "bearer $accessToken",
          }
        },
      );
      var jsonDecoded = jsonDecode(response.body);

      log('Video Data: id -> $videoId | access token -> $accessToken');

      var jsonData = jsonDecoded['files'];

      SplayTreeMap videoList = SplayTreeMap.fromIterable(
        jsonData,
        key: (item) => "${item['rendition']} ${item['fps']}",
        value: (item) => item['link'],
      );

      log("video qualities ${videoList.values}");
      return videoList;
    } catch (error) {
      log('=====> REQUEST ERROR: $error');
      return null;
    }
  }
}
