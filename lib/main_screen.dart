// 2023 FMNX team.
// Use of this code is governed by GNU General Public License.
// Additional information can be found on official web page: https://fmnx.su/
// Contact email: help@fmnx.su

import 'package:repo/components/header.dart';
import 'package:repo/components/outdated_packages.dart';
import 'package:repo/components/package_info_board.dart';
import 'package:repo/components/side_menu.dart';
import 'package:repo/constants.dart';
import 'package:repo/controllers/menu_app_controller.dart';
import 'package:repo/generated//pack.pb.dart';
import 'package:repo/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DescribeResponse descr = DescribeResponse();
  StatsResponse stats = StatsResponse();

  updateInformation(String text) async {
    var newDescr = await stub.describe(
      DescribeRequest(package: text),
    );
    var newStats = await stub.stats(StatsRequest());
    setState(() {
      descr = newDescr;
      stats = newStats;
    });
  }

  updatePackage(String text) async {
    var newDescr = await stub.describe(
      DescribeRequest(package: text),
    );
    setState(() {
      descr = newDescr;
    });
  }

  @override
  void initState() {
    super.initState();
    updateInformation("git");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(
        refreshPage: (text) {
          updatePackage(text);
        },
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(
                  refreshPage: (text) {
                    updatePackage(text);
                  },
                ),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: SafeArea(
                child: SingleChildScrollView(
                  primary: false,
                  padding: EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      Header(),
                      SizedBox(height: defaultPadding),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                if (Responsive.isMobile(context))
                                  OutdatedPackages(
                                    updateCallback: () {
                                      updateInformation(descr.name);
                                    },
                                    outdated: stats.outdatedCount.toDouble(),
                                    total: stats.packagesCount.toDouble(),
                                    outdatedPackagesList:
                                        stats.outdatedPackages,
                                  ),
                                if (Responsive.isMobile(context))
                                  SizedBox(height: defaultPadding),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 644),
                                  child: PackageInfoBoard(
                                    key: UniqueKey(),
                                    description: descr,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!Responsive.isMobile(context))
                            SizedBox(width: defaultPadding),
                          if (!Responsive.isMobile(context))
                            Expanded(
                              flex: 2,
                              child: OutdatedPackages(
                                updateCallback: () {
                                  updateInformation(descr.name);
                                },
                                outdated: stats.outdatedCount.toDouble(),
                                total: stats.packagesCount.toDouble(),
                                outdatedPackagesList: stats.outdatedPackages,
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
