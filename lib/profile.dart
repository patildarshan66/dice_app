import 'dart:async';

import 'package:dice_app/authentication/vm_authentication.dart';
import 'package:dice_app/additionalFiles/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

import 'additionalFiles/routes.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = '';
  String _email = '';
  String _profilePicUrl = '';
  String _version = '';

  StreamController<bool> _versionController = StreamController.broadcast();

  @override
  void dispose() {
    _versionController.close();
    super.dispose();
  }

  @override
  void initState() {
    _getVersion();
    final vmAuth = Provider.of<VmAuthentication>(context, listen: false);
    _name = vmAuth.username;
    _email = vmAuth.email;
    _profilePicUrl = vmAuth.profilePicUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: largePadding),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(_profilePicUrl),
                radius: 50,
              ),
              const SizedBox(height: mediumHeightWidth),
              getTile(_name, Icons.person),
              getTile(_email, Icons.email),
              StreamBuilder(
                  stream: _versionController.stream,
                  builder: (ctx, snapshot) =>
                      getTile('Version: $_version', Icons.phone_android)),
              getTile('Logout', Icons.logout, onTap: _showLogoutDialog),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    Provider.of<VmAuthentication>(context, listen: false).logout();
    Navigator.pop(context);
    Navigator.of(context).pushNamedAndRemoveUntil(
        MyRoutes.mainPage, (Route<dynamic> route) => false);
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    _versionController.add(true);
  }

  Widget getTile(String label, IconData icon, {Function onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:const Text(
          'warning',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('No')),
          TextButton(
            onPressed: _logout,
            child: const Text('Yes'),
          )
        ],
      ),
    );
  }
}
