import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'custom_colors.dart';

class MorePage extends StatefulWidget {
  const MorePage({
    Key? key,
    required this.darkMode,
    required this.changeColorMode,
  }) : super(key: key);

  final bool darkMode;
  final Function() changeColorMode;

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  void initState() {
    super.initState();
    retrieveFactoredTime();
  }

  late Tuple2 factoredTime = const Tuple2(0, 0);

  @override
  Widget build(BuildContext context) {
    // Size Assets
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // print("W: $screenWidth  H: $screenHeight");

    final double width = screenWidth * 0.84;
    final double height = screenHeight * 0.94;

    final double pageTitleHeight = height * 0.14;

    final double toggleHeight = height * 0.08;

    return Scaffold(
      backgroundColor:
          widget.darkMode == false ? CColors.lightGrey : CColors.darkGrey,
      body: Align(
        alignment: const Alignment(0, 0.3),
        child: SizedBox(
          // width: width,
          height: height,
          child: Column(
            children: [
              SizedBox(
                // color: Colors.red,
                height: pageTitleHeight,
                child: Text(
                  "More",
                  style: GoogleFonts.poppins(
                    color: widget.darkMode == false
                        ? CColors.black
                        : CColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
              Toggle(
                width: width,
                toggleHeight: toggleHeight,
                darkMode: widget.darkMode,
                title: "Dark Mode",
                value: widget.darkMode == false ? "Off" : "On",
                action: widget.changeColorMode,
              ),
              SizedBox(height: height * 0.03),
              Toggle(
                width: width,
                toggleHeight: toggleHeight,
                darkMode: widget.darkMode,
                title: "Day Change",
                value: displayFactoredTime(),
                action: () {
                  showBottomPicker(context: context, initialTime: factoredTime);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setFactoredTime({required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("Factored Time", value);

    final String val1 = value.substring(0, 2);
    final String val2 = value.substring(3, 5);
    final Tuple2 tuple = Tuple2(int.parse(val1), int.parse(val2));
    setState(() {
      factoredTime = tuple;
    });
  }

  Future<void> retrieveFactoredTime() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("Factored Time")) {
      final String? value = prefs.getString("Factored Time");

      if (value != null) {
        final String val1 = value.substring(0, 2);
        final String val2 = value.substring(3, 5);
        final Tuple2 tuple = Tuple2(int.parse(val1), int.parse(val2));

        factoredTime = tuple;
      }
    }

    setState(() {});
  }

  String displayFactoredTime() {
    int value1 = factoredTime.item1;
    int value2 = factoredTime.item2;

    String text1 = "$value1";
    String text2 = "$value2";

    if (value1 == 0) {
      text1 = "0$value1";
    }

    if (value2 < 10) {
      text2 = "0$value2";
    }

    return "$text1:$text2";
  }

  void showBottomPicker(
      {required BuildContext context, required Tuple2 initialTime}) {
    BottomPicker.time(
      title: "The hour at which the day changes:",
      //                         ..., hour, minutes)
      initialDateTime: DateTime(
        0,
        0,
        0,
        initialTime.item1,
        initialTime.item2,
      ),
      titleStyle: GoogleFonts.poppins(
        color: widget.darkMode == false ? CColors.black : CColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      use24hFormat: true,
      pickerTextStyle: GoogleFonts.poppins(
        color: widget.darkMode == false ? CColors.black : CColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
      closeIconColor: widget.darkMode == false ? CColors.black : CColors.white,
      iconColor: widget.darkMode == false ? CColors.white : CColors.black,
      backgroundColor: widget.darkMode == false ? CColors.white : CColors.black,
      buttonSingleColor:
          widget.darkMode == false ? CColors.black : CColors.white,
      onSubmit: (p0) {
        final String value = p0.toString().substring(12, 17);
        setFactoredTime(value: value);
      },
    ).show(context);
  }
}

class Toggle extends StatelessWidget {
  const Toggle({
    Key? key,
    required this.width,
    required this.toggleHeight,
    required this.darkMode,
    required this.title,
    required this.value,
    required this.action,
  }) : super(key: key);

  final double width;
  final double toggleHeight;
  final bool darkMode;

  final String title;
  final String value;
  final Function() action;

  @override
  Widget build(BuildContext context) {
    final double box1Width = width * 0.582;
    final double lineWidth = width * 0.006;
    final double box2Width = width * 0.412;

    return Container(
      width: width,
      height: toggleHeight,
      decoration: BoxDecoration(
        color: darkMode == false ? CColors.white : CColors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: box1Width,
            alignment: Alignment.center,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: darkMode == false ? CColors.black : CColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            color: darkMode == false ? CColors.black : CColors.white,
            width: lineWidth,
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              splashColor:
                  darkMode == false ? CColors.darkGrey : CColors.lightGrey,
              onTap: action,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: Container(
                width: box2Width,
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: darkMode == false ? CColors.black : CColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class InputToggle extends StatelessWidget {
//   const InputToggle({
//     Key? key,
//     required this.width,
//     required this.toggleHeight,
//     required this.darkMode,
//     required this.title,
//     required this.value,
//     required this.action,
//   }) : super(key: key);

//   final double width;
//   final double toggleHeight;
//   final bool darkMode;

//   final String title;
//   final String value;
//   final Function() action;

//   @override
//   Widget build(BuildContext context) {
//     final double box1Width = width * 0.582;
//     final double lineWidth = width * 0.006;
//     final double box2Width = width * 0.412;

//     late String inputValue = "00:00";
//     final TextEditingController controller =
//         TextEditingController(text: inputValue);

//     return Container(
//       width: width,
//       height: toggleHeight,
//       decoration: BoxDecoration(
//         color: darkMode == false ? CColors.white : CColors.black,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: box1Width,
//             alignment: Alignment.center,
//             child: Text(
//               title,
//               style: GoogleFonts.poppins(
//                 color: darkMode == false ? CColors.black : CColors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//           Container(
//             color: darkMode == false ? CColors.black : CColors.white,
//             width: lineWidth,
//           ),
//           Container(
//             width: box2Width,
//             // alignment: Alignment.center,
//             decoration: const BoxDecoration(
//               color: Colors.red,
//               borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(15),
//                 bottomRight: Radius.circular(15),
//               ),
//             ),
//             child: TextFormField(
//               controller: controller,
//               textAlign: TextAlign.center,
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 if (value.length == 2) {
//                   value += ":";
//                   print(value);
//                   controller.text = "${controller.text}:";
//                   controller.
//                 }
//               },
//               onTap: () {
//                 controller.text = "";
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }