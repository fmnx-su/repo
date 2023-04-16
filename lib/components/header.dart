import 'package:fmnxpkg/components/upload_file.dart';
import 'package:fmnxpkg/controllers/menu_app_controller.dart';
import 'package:fmnxpkg/generated/v1/pacman.pb.dart';
import 'package:fmnxpkg/responsive.dart';
import 'package:fmnxpkg/components/add_pkg_popup.dart';
import 'package:fmnxpkg/components/flue_button.dart';
import 'package:fmnxpkg/components/login_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Pacman package repository",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        ProfileCard(),
      ],
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  Widget placeholder = Placeholder();

  trySetAuthorized() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token") ?? "";
    if (token != "") {
      var resp = await stub.checkToken(CheckTokenRequest(
        token: token,
      ));
      if (resp.upToDate) {
        setState(() {
          placeholder = AuthorizedActions();
        });
      }
    }
  }

  @override
  void initState() {
    placeholder = UnauthorizedWidget(loggedCallback: () async {
      await trySetAuthorized();
    });
    super.initState();
    trySetAuthorized();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      child: placeholder,
    );
  }
}

class UnauthorizedWidget extends StatelessWidget {
  final void Function() loggedCallback;
  const UnauthorizedWidget({
    Key? key,
    required this.loggedCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FmnxButton(
          text: "Authorize",
          icon: Icons.lock_open,
          onPressed: () {
            showLoginScreen(context, loggedCallback);
          },
        ),
      ],
    );
  }
}

class AuthorizedActions extends StatelessWidget {
  const AuthorizedActions({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FmnxButton(
          text: "Upload file",
          icon: Icons.add,
          onPressed: () {
            uploadFile(context);
          },
        ),
        SizedBox(width: defaultPadding),
        FmnxButton(
          text: "Add from AUR",
          icon: Icons.add,
          onPressed: () {
            showAddPackage(context);
          },
        ),
      ],
    );
  }
}
