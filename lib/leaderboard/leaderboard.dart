import 'package:dice_app/additionalFiles/offline_data_manager.dart';
import 'package:dice_app/additionalFiles/constants.dart';
import 'package:dice_app/leaderboard/vm_leaderboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../additionalFiles/global_functions_variables.dart';
import 'model_leaderboard.dart';

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  void initState() {
    _callApi();
    super.initState();
  }

  TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  TextStyle headerTextStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: RefreshIndicator(
            onRefresh: _callApi,
            child: Consumer<VmLeaderboard>(
              builder: (ctx, vmLeaderboard, ch) {
                String msg = 'Loading...';
                if (vmLeaderboard.responseState == requestResponseState.Error) {
                  msg = "Server Error";
                }
                return vmLeaderboard.responseState ==
                        requestResponseState.DataReceived
                    ? Column(
                        children: [
                          _header(),
                          Expanded(
                              child:
                                  _showList(vmLeaderboard.getLeaderboardList)),
                        ],
                      )
                    : Center(child: Text(msg));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _showList(List<ModelLeaderboard> list) {
    list.sort((a, b) => b.highScore.compareTo(a.highScore));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: smallPadding),
      itemBuilder: (ctx, i) => _listItem(list[i], i + 1),
      itemCount: list.length,
    );
  }

  Widget _listItem(ModelLeaderboard obj, int position) {
    return Container(
      padding: const EdgeInsets.all(smallPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getTopLeaderColor(position),
                radius: 20,
                child: Text(
                  position.toString(),
                  style: textStyle,
                ),
              ),
              Expanded(
                  child: Text(
                obj.userName,
                textAlign: TextAlign.center,
                style: textStyle,
              )),
              Text(
                obj.highScore.toString(),
                style: textStyle,
              ),
              const SizedBox(width: 5)
            ],
          ),
          Divider(color: Colors.grey.shade100, thickness: 2)
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(mediumPadding),
      color: Colors.blue,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Rank', style: headerTextStyle),
          Text('Name', style: headerTextStyle),
          Text('Score', style: headerTextStyle)
        ],
      ),
    );
  }

  Color _getTopLeaderColor(int position) {
    Color color = Colors.white;
    switch (position) {
      case 1:
        color = Colors.amber.shade400;
        break;
      case 2:
        color = Colors.blueGrey.shade100;
        break;
      case 3:
        color = Colors.brown;
        break;
      default:
        color = Colors.white;
        break;
    }
    return color;
  }

  Future<void> _callApi() async {
    bool isNet = await checkNetwork();
    if (!isNet) {
      showCustomSnackBar(
          context, 'You are offline. Leaderboard may be not updated.',
          color: Colors.red);
    }
    Provider.of<VmLeaderboard>(context, listen: false).fetchLeaderboard();
  }
}
