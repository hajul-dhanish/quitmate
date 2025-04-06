import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quitmate/systems/calendar_controller.dart';
import 'package:quitmate/systems/count_controller.dart';
import 'package:quitmate/systems/helpers/custom_colors.dart';
import 'package:quitmate/pages/more_page.dart';
import 'package:quitmate/pages/home_page.dart';
import 'package:quitmate/systems/helpers/custom_functions.dart';
import 'package:quitmate/systems/data_controller.dart';

void main() {
  runApp(const MaterialApp(
    home: MainPage(),
    debugShowCheckedModeBanner: false,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Data Controller
  final DataController dataController = DataController();

  // Count Controller
  late CountController countController;

  // Count Controller
  late CalendarController calendarController;

  // Page Controller for scroling between the MainPage and MorePage
  final PageController pageController = PageController(initialPage: 0);

  // Keep check if data finished loading
  late bool loaded = false;

  @override
  void initState() {
    super.initState();
    grantPermissions().then(
        (value) => dataController.load().then((value) => finishLoading()));
  }

  void updateCounter() {
    void refreshState() {
      setState(() {
        calendarController = CalendarController(dataController: dataController);
        countController = CountController(dataController: dataController);
      });
    }

    dataController.performChecks().then((value) => refreshState());
  }

  void finishLoading() {
    setState(() {
      colorMode = dataController.getColorMode();
      amoled = dataController.getAmoled();
      dayChangeTime = dataController.getDayChangeTime();
      sunSetTime = dataController.getSunSetTime();
      dailyLimit = dataController.getLimit();

      setNewSunSetTime(int.parse(sunSetTime.replaceAll(":", "")));

      calendarController = CalendarController(dataController: dataController);
      countController = CountController(dataController: dataController);

      loaded = true;
    });
  }

  Future<void> grantPermissions() async {
    // if (Platform.isAndroid) {
    //   bool granted = await Permission.manageExternalStorage.request().isGranted;
    //   while (!granted) {
    //     granted = await Permission.manageExternalStorage.request().isGranted;
    //   }
    // }
  }

  void changeColorMode() {
    setState(() {
      String tempColorMode = dataController.getColorMode();
      colorMode = cycleColorMode(colorMode: tempColorMode);
      dataController.setSetting(key: "Color Mode", value: colorMode);
    });
  }

  void changeAmoledMode() {
    setState(() {
      bool tempAmoled = dataController.getAmoled();
      amoled = !tempAmoled;
      dataController.setSetting(key: "Amoled", value: amoled);
    });
  }

  void updateFactoredTime({required String newFactoredTime}) {
    setState(() {
      dayChangeTime = newFactoredTime;
      dataController
          .setSetting(key: "Day Change Time", value: dayChangeTime)
          .then((value) => updateCounter());
    });
  }

  void updateSunSetTime({required String newSunSetTime}) {
    setState(() {
      sunSetTime = newSunSetTime;
      dataController.setSetting(key: "Sun Set Time", value: sunSetTime);
      setNewSunSetTime(int.parse(sunSetTime.replaceAll(":", "")));
    });
  }

  void updateDailyLimit({required int newDailyLimit}) {
    setState(() {
      dailyLimit = newDailyLimit;
      log(title: "Main (updateDailyLimit)", value: dailyLimit);
      dataController.setSetting(key: "Daily Limit", value: dailyLimit);
      dataController
          .setSetting(key: "Daily Limit", value: dailyLimit)
          .then((value) => updateCounter());
    });
  }

  // Build Assets
  late String colorMode = dataController.defaultColorMode;
  late bool amoled = dataController.defaultAmoled;
  late String dayChangeTime = dataController.defaultDayChangeTime;
  late String sunSetTime = dataController.defaultSunSetTime;
  late int dailyLimit = dataController.defaultLimit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CColors.black,
      body: Center(
        child: loaded
            ? PageView(
                controller: pageController,
                children: [
                  HomePage(
                    colorMode: colorMode,
                    isAmoled: amoled,
                    firstDate: dataController.getFirstDate(),
                    dataController: dataController,
                    calendarController: calendarController,
                    countController: countController,
                  ),
                  MorePage(
                    colorMode: colorMode,
                    isAmoled: amoled,
                    changeColorMode: changeColorMode,
                    changeAmoledMode: changeAmoledMode,
                    factoredTimeString: dayChangeTime,
                    updateFactoredTime: updateFactoredTime,
                    sunSetTimeString: sunSetTime,
                    updateSunSetTime: updateSunSetTime,
                    countController: countController,
                    dailyLimit: dailyLimit,
                    updateDailyLimit: updateDailyLimit,
                  )
                ],
              )
            : const CircularProgressIndicator(
                color: CColors.white,
              ),
      ),
    );
  }
}
