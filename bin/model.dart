import 'dart:convert';
import 'dart:io';
import 'dart:math';

Hiscores loadHiscores(File file) {
  return new Hiscores.loadFromJson('{"capacity": 10, "scores": [{"name":"test1", "score":1}, {"name":"test2", "score":2}]}');
}

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
    return '{"name":"$name", "score":"$score"}';
  }
}

class Hiscores {
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
      sb.write('"capacity": "$capacity",[');
      scores.forEach((score) {
        sb.write(score.toJson() + "\n");
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
  }
}