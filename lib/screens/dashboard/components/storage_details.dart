import 'package:ctlpkg/generated/v1/pacman.pb.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'chart.dart';
import 'storage_info_card.dart';

class OutdatedPackages extends StatelessWidget {
  final double outdated;
  final double total;
  final List<OutdatedPackage> outdatedPackagesList;
  const OutdatedPackages({
    Key? key,
    required this.outdated,
    required this.total,
    required this.outdatedPackagesList,
  }) : super(key: key);

  List<StorageInfoCard> convertPackages(
      List<OutdatedPackage> outdatedPackagesList) {
    List<StorageInfoCard> output = [];
    outdatedPackagesList.forEach((element) {
      output.add(StorageInfoCard(
        name: element.name,
        latestVersion: element.latestVersion,
        currVersion: element.currentVersion,
      ));
    });
    return output;
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
          Chart(
            outdated: outdated,
            uptodate: total - outdated,
          ),
          Container(
            height: 420,
            child: ListView(
              children: convertPackages(outdatedPackagesList),
            ),
          ),
        ],
      ),
    );
  }
}
