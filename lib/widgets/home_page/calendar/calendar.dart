import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quitmate/systems/calendar_controller.dart';
import 'package:quitmate/widgets/home_page/calendar/day_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    Key? key,
    required this.width,
    required this.height,
    required this.background,
    required this.fill,
    required this.disabled,
    required this.symbol,
    required this.subText,
    required this.calendarController,
    required this.refreshStats,
  }) : super(key: key);

  final double width;
  final double height;

  final Color background;
  final Color fill;
  final Color disabled;
  final Color symbol;
  final Color subText;

  final CalendarController calendarController;

  final Function() refreshStats;

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  late bool loaded = false;

  late List<int> values = [-1, -1, -1, -1, -1, -1, -1];
  late List<double> oldHeights = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    loadWeekData();
  }

  Future<void> loadWeekData() async {
    getWeekData();

    loaded = true;
  }

  void getWeekData() {
    widget.calendarController.getData();
    values = widget.calendarController.values;
  }

  void refresh() {
    setState(() {
      setOldHeights();
      getWeekData();
    });
  }

  final double centerScaleFactor = 0.74;
  final double sidesScaleFactor = 0.13;
  final double bottomScaleFactor = 0.16;

  final double dayCalendarWidthFactor = 0.08;
  final double dayCalendarHeightFactor = 1;

  void setOldHeights() {
    for (int i = 0; i <= 6; i++) {
      if (values[i] >= 0) {
        final double h =
            (widget.height * dayCalendarHeightFactor * 0.6) * (values[i] / max);
        oldHeights[i] = h;
      } else {
        oldHeights[i] = 0;
      }
    }
  }

  String getText() {
    return widget.calendarController.range;

    // if (widget.calendarController.weekoffset ==
    //     widget.calendarController.weekgroup) {
    //   return "Showing stats from current week";
    // } else if (widget.calendarController.weekoffset + 1 ==
    //     widget.calendarController.weekgroup) {
    //   return "Showing stats from 1 week in the past";
    // } else {
    //   int diff = widget.calendarController.weekgroup -
    //       widget.calendarController.weekoffset;
    //   return "Showing stats from ${diff} weeks in the past";
    // }
  }

  late List<GlobalKey<DayCallendarState>> dayCalendarkeys = [];

  static const List<String> symbols = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Widget instansiateDC({
    required int index,
  }) {
    final GlobalKey<DayCallendarState> key = GlobalKey();
    dayCalendarkeys.add(key);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: DayCallendar(
        key: key,
        width: widget.width * 0.076,
        height: widget.height * dayCalendarHeightFactor,
        symbol: symbols[index],
        background: widget.background,
        fill: widget.fill,
        disabled: widget.disabled,
        symbolColor: widget.symbol,
        max: max,
        value: values[index],
        oldHeight: oldHeights[index],
      ),
    );
  }

  late int max;
  @override
  Widget build(BuildContext context) {
    max = widget.calendarController.max;

    return loaded
        ? Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    // color: Colors.red.withOpacity(0.4),
                    width: widget.width * sidesScaleFactor,
                    height: widget.height,
                    child: Center(
                      //! Left Button
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            setOldHeights();
                            widget.calendarController.moveBack();
                            widget.refreshStats();
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            setOldHeights();
                            widget.calendarController.moveToFirst();
                            widget.refreshStats();
                          });
                        },
                        style: TextButton.styleFrom(
                            fixedSize: Size(
                              widget.width * sidesScaleFactor,
                              widget.width * sidesScaleFactor,
                            ),
                            foregroundColor: widget.subText.withOpacity(0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45),
                            )),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: widget.calendarController.weekoffset == 0
                              ? widget.subText.withOpacity(0.25)
                              : widget.subText.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    // color: Colors.blueAccent.withOpacity(0.4),
                    width: widget.width * centerScaleFactor,
                    height: widget.height,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 7; i++) instansiateDC(index: i),
                        ]),
                  ),
                  SizedBox(
                    // color: Colors.red.withOpacity(0.4),
                    width: widget.width * sidesScaleFactor,
                    height: widget.height,
                    child: Center(
                      //! Right Button
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            setOldHeights();
                            widget.calendarController.moveForward();
                            widget.refreshStats();
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            setOldHeights();
                            widget.calendarController.moveToLast();
                            widget.refreshStats();
                          });
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size(
                            widget.width * sidesScaleFactor,
                            widget.width * sidesScaleFactor,
                          ),
                          foregroundColor: widget.subText.withOpacity(0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: widget.calendarController.weekoffset ==
                                  widget.calendarController.weekgroup
                              ? widget.subText.withOpacity(0.25)
                              : widget.subText.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                // color: Colors.yellowAccent.withOpacity(0.4),
                width: widget.width,
                height: widget.height * bottomScaleFactor,
                alignment: Alignment.bottomCenter,
                child: Text(
                  getText(),
                  style: GoogleFonts.poppins(
                    color: widget.subText.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          )
        : Container(
            height: widget.height + widget.height * bottomScaleFactor,
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: widget.fill,
              ),
            ),
          );
  }
}
