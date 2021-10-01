import 'package:meta/meta.dart';
import 'dart:convert';

ModelLeaderboard modelLeaderboardFromJson(String str) =>
    ModelLeaderboard.fromJson(json.decode(str));

String modelLeaderboardToJson(ModelLeaderboard data) =>
    json.encode(data.toJson());

List<ModelLeaderboard> modelLeaderboardFromList(var str) =>
    List<ModelLeaderboard>.from(
        str.map((x) => ModelLeaderboard.fromJson(x.data())));

String modelLeaderboardListToJson(List<ModelLeaderboard> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ModelLeaderboard {
  ModelLeaderboard({
    @required this.userName,
    @required this.highScore,
  });

  final String userName;
  final int highScore;

  factory ModelLeaderboard.fromJson(Map<String, dynamic> json) =>
      ModelLeaderboard(
        userName: json["userName"],
        highScore: json["highScore"],
      );

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "highScore": highScore,
      };
}
