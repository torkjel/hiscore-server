import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';


class PlayerScore {
  final String name;
  final int score;

  PlayerScore(this.name, this.score);

  PlayerScore.loadFromJsonData(Map<String, Object> data)
    : name = data['name'],
      score = data['score'];

  factory PlayerScore.loadFromJson(String json) {
    return new PlayerScore.loadFromJsonData(JSON.decode(json));
  }

  String toJson() {
    return '{"name":"$name", "score":$score}';
  }
}

class Hiscores {

  static File getHiscoresFile() {
    var userHome = Platform.environment["HOME"];
    if (userHome != null && userHome.length > 0) {
      return new File("$userHome/hiscores.json");
    } else {
      throw new Exception("No home dir $userHome");
    }
  }

  static Future<Hiscores> load() {
    var hiscoresFile = getHiscoresFile();
    return hiscoresFile.exists().then(
        (fileExists) => fileExists ? Hiscores.loadFromFile(hiscoresFile) : new Hiscores());
  }

  static Future<Hiscores> loadFromFile(File hiscoresFile) {
    return hiscoresFile.readAsString().then((jsonString) => new Hiscores.loadFromJson(jsonString));
  }

  int capacity;
  final List<PlayerScore> scores = new List<PlayerScore>();

  Hiscores() {
    capacity = 10;
  }

  Hiscores.loadFromJson(String json) {
    Map<String, Object> data = JSON.decode(json);
    this.capacity = data["capacity"];
    List<Map> scoreList = data["scores"];
    scoreList.forEach((Map scoreData) {
      scores.add(new PlayerScore.loadFromJsonData(scoreData));
    });
  }

  String toJson() {
      var sb = new StringBuffer();
      sb.write("{");
      sb.write('"capacity": $capacity, "scores": [');
      scores.forEach((score) {
        sb.write(score.toJson());
        if (scores.last != score)
          sb.write(',');
      });
      sb.write(']}');
      return sb.toString();
  }

  void register(PlayerScore ps) {
    for (int n = 0; n < min(capacity, scores.length + 1); n++) {
      if (n >= scores.length) {
        scores.add(ps);
        break;
      } else if (scores[n].score < ps.score) {
        scores.insert(n, ps);
        break;
       }
    }
    if (scores.length > capacity)
      scores.removeLast();
    save();
  }

  void save() {
    File hiscoresFile = getHiscoresFile();
    IOSink sink = hiscoresFile.openWrite();
    sink.write(toJson());
    sink.close();
  }
}