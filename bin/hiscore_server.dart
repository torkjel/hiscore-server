import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'model.dart';

void main() {

  HttpServer.bind("127.0.0.1", 8080).then((server) {
    server.listen((HttpRequest request) {
      print("Handling ${request.method} ${request.uri}");
      if (request.method == 'POST' && request.uri.path == "/score")
        handleNewScore(request);
      else {
        request.response.statusCode = 404;
        request.response.write("Not found...");
        request.response.close();
      }
    });
  });
}

void handleNewScore(HttpRequest request) {
  var body = [];
  request.listen((List<int> buffer) => buffer != null ? body.addAll(buffer) : null,
    onDone: () {
      var newScore = new PlayerScore.loadFromJson(new Utf8Decoder().convert(body));
      Hiscores.load().then((hiscores) {
        hiscores.register(newScore);
        request.response.close();
        print("registered new score ${newScore.toJson()}");
        print("hiscores is now ${hiscores.toJson()}");
      });
    }
  );
}

