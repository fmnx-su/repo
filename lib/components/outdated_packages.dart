import 'package:fmnx_pkg/generated/v1/pacman.pb.dart';
import 'package:fmnx_pkg/components/fmnx_button.dart';
import 'package:fmnx_pkg/components/update_packages.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'package_chart.dart';
import 'outdated_package_card.dart';

class OutdatedPackages extends StatelessWidget {
  final double outdated;
  final double total;
  final List<OutdatedPackage> outdatedPackagesList;
  final void Function() updateCallback;
  const OutdatedPackages({
    Key? key,
    required this.outdated,
    required this.total,
    required this.outdatedPackagesList,
    required this.updateCallback,
  }) : super(key: key);

  List<OutdatedPackageCard> convertPackages(
      List<OutdatedPackage> outdatedPackagesList) {
    List<OutdatedPackageCard> output = [];
    outdatedPackagesList.forEach((element) {
      output.add(OutdatedPackageCard(
        name: element.name,
        latestVersion: element.latestVersion,
        currVersion: element.currentVersion,
      ));
    });
    return output;
  }

  double getHeight(double outdated) {
    if (outdated == 1.0) {
      return 94;
    }
    if (outdated == 2.0) {
      return 188;
    }
    if (outdated == 3.0) {
      return 282;
    }
    return 396;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Outdated packages",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          PackageChart(
            outdated: outdated,
            uptodate: total - outdated,
          ),
          Container(
            height: getHeight(outdated),
            child: ListView(
              children: convertPackages(outdatedPackagesList),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: FmnxButton(
                text: "Update",
                icon: Icons.refresh,
                onPressed: () {
                  showUpdateNotification(context, updateCallback);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
