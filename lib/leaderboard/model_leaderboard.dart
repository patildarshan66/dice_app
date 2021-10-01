import 'package:meta/meta.dart';
import 'dart:convert';

List<ModelLeaderboard> modelLeaderboardFromListFirestore(var str) =>
    List<ModelLeaderboard>.from(
        str.map((x) => ModelLeaderboard.fromJson(x.data())));

List<ModelLeaderboard> modelLeaderboardFromListOffline(var str) =>
    List<ModelLeaderboard>.from(str.map((x) => ModelLeaderboard.fromJson(x)));

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
