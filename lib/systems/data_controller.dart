import 'package:smoking_regulator_v2/systems/custom_functions.dart';
import 'package:smoking_regulator_v2/systems/save_system.dart';

class DataController {
  late Map<String, dynamic> data = {};
  late Map<String, dynamic> settings = {};
  late Map<String, dynamic> week = {};

  final SaveSystem saveSystem = SaveSystem();

  // ----- Editing and Saving System ---------------
  Future<void> setData({required String key, required dynamic value}) async {
    week[key] = value;
    data[getWeekGroup().toString()] = week;
    await saveSystem.save(filename: saveSystem.data, data: data);
  }

  dynamic getfromWeek({required String weekdayKey}) {
    return week[weekdayKey];
  }

  dynamic getfromData({int? weekgroupkey}) {
    if (weekgroupkey == null) {
      return data[getWeekGroup().toString()];
    }
    return data[weekgroupkey.toString()];
  }

  Future<void> setSetting({required String key, required dynamic value}) async {
    settings[key] = value;
    await saveSystem.save(filename: saveSystem.settings, data: settings);
  }

  dynamic getfromSettings({required String key}) {
    return settings[key];
  }

  // ----- Defaults ---------------
  String defaultColorMode = "Light";
  String getColorMode() {
    String value = getfromSettings(key: "ColorMode") ?? defaultColorMode;
    return value;
  }

  bool defaultAmoled = false;
  bool getAmoled() {
    bool value = getfromSettings(key: "Amoled") ?? defaultAmoled;
    return value;
  }

  String defaultDayChangeTime = "0000";
  String getDayChangeTime() {
    String value =
        getfromSettings(key: "DayChangeTime") ?? defaultDayChangeTime;
    return value;
  }

  String getFirstDate() {
    String defaultValue = datetoString(getDateTime(this));
    if (getfromSettings(key: "FirstDate") == null) {
      setSetting(key: "FirstDate", value: defaultValue);
      return defaultValue;
    }

    return getfromSettings(key: "FirstDate");
  }

  String getLastDate() {
    String defaultValue = datetoString(getDateTime(this));
    if (getfromSettings(key: "LastDate") == null) {
      setSetting(key: "LastDate", value: defaultValue);
      return defaultValue;
    }

    return getfromSettings(key: "LastDate");
  }

  int getLastWeekDay() {
    if (getfromSettings(key: "LastWeekDay") == null) {
      setSetting(key: "LastWeekDay", value: 0);
      return 0;
    }

    return getfromSettings(key: "LastWeekDay");
  }

  int getWeekGroup() {
    DateTime datenow = getDateTime(this);
    DateTime firstdate = DateTime.parse(getFirstDate());
    DateTime firstWeekDate =
        firstdate.subtract(Duration(days: firstdate.weekday - 1));

    // log(
    //     title: "Data Controller (getWeekGroup)",
    //     value:
    //         "First Week Date: $firstWeekDate  First Date: $firstdate  Date Now: $datenow");

    int difference = datenow.difference(firstWeekDate).inDays;

    // log(
    //     title: "Data Controller (getWeekGroup)",
    //     value: "Difference: $difference");

    // log(
    //     title: "Data Controller (getWeekGroup)",
    //     value: "First Date Day: ${firstdate.weekday}");

    // difference += firstdate.weekday + 1;

    int newWeekgroup = difference ~/ 7;

    log(title: "Data Controller (getWeekGroup)", value: newWeekgroup);

    return newWeekgroup;
  }

  Map<String, dynamic>? getDayData(String weekdayKey) {
    if (getfromWeek(weekdayKey: weekdayKey) == null) {
      return null;
    }

    log(
        title: "Data Controller (getDayData)",
        value: "$weekdayKey : ${getfromWeek(weekdayKey: weekdayKey)}");
    return getfromWeek(weekdayKey: weekdayKey);
  }

  int getCountSum() {
    if (getfromSettings(key: "CountSum") == null) {
      setSetting(key: "CountSum", value: 0);
      return 0;
    }

    return getfromSettings(key: "CountSum");
  }

  int getPopulation() {
    if (getfromSettings(key: "Population") == null) {
      setSetting(key: "Population", value: 1);
      return 1;
    }

    return getfromSettings(key: "Population");
  }

  int defaultLimit = 5;
  int getLimit() {
    if (getfromSettings(key: "DailyLimit") == null) {
      setSetting(key: "DailyLimit", value: defaultLimit);
      return defaultLimit;
    }

    return getfromSettings(key: "DailyLimit");
  }

  // ----- Loading System ---------------
  Future<void> load() async {
    await saveSystem.initializePath();
    await loadSettings();
    await loadData();
  }

  Future<void> loadSettings() async {
    Map<String, dynamic>? tempSettings =
        await saveSystem.load(filename: saveSystem.settings);

    if (tempSettings != null) {
      settings = tempSettings;
      log(title: "Data Controller (loadSettings)", value: "Settings Loaded");
    } else {
      settings = {};
      log(title: "Data Controller (loadSettings)", value: "Did not load");
    }
  }

  Future<void> loadData() async {
    await performChecks();

    Map<String, dynamic>? tempData =
        await saveSystem.load(filename: saveSystem.data);

    if (tempData != null) {
      data = tempData;
      Map<String, dynamic>? tempWeek = getfromData();
      if (tempWeek == null) {
        week = {};
        log(title: "Data Controller (loadData)", value: "Did not load");
      } else {
        week = tempWeek;
        // log(title: "Data Controller (loadData)", value: "Current Week: $week");
        log(title: "Data Controller (loadData)", value: "Data Loaded");
      }
      log(title: "Data Controller (loadData)", value: data);
    } else {
      data = {};
      log(title: "Data Controller (loadData)", value: "Did not load");
    }
  }

  // ----- Checks ---------------
  Future<void> performChecks() async {
    checkPopulation();
    checkLastDate();

    log(title: "Data Controller (performChecks)", value: "Checks Performed");
  }

  void checkPopulation() {
    DateTime datenow = getDateTime(this);
    DateTime lastdate = DateTime.parse(getLastDate());

    bool isAfter = dateTimeIsBigger(datenow, lastdate);
    int popvalue = getPopulation();
    if (isAfter) {
      setSetting(key: "Population", value: popvalue + 1);
    }
  }

  void checkLastDate() {
    DateTime datenow = getDateTime(this);
    DateTime lastdate = DateTime.parse(getLastDate());

    bool isAfter = dateTimeIsBigger(datenow, lastdate);
    if (isAfter) {
      setSetting(key: "LastDate", value: datetoString(datenow));
    }
    log(title: "Data Controller (checkLastDate)", value: datetoString(datenow));
  }
}
