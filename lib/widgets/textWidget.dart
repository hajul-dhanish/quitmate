import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../systems/helpers/custom_colors.dart';

Text textWidget(
    {required String title,
    required colorMode,
    required isAmoled,
    required active,
    required fontSize}) {
  return Text(
    title,
    textAlign: TextAlign.end,
    style: GoogleFonts.poppins(
      color: getColor(
        colorMode: colorMode,
        isAmoled: isAmoled,
        light: active ? CColors.dark : CColors.darkGrey,
        dark: active
            ? CColors.white
            : Color.lerp(CColors.lightGrey, CColors.darkGrey, 0.5) as Color,
        amoled: active
            ? CColors.white
            : Color.lerp(CColors.lightGrey, CColors.darkGrey, 0.6) as Color,
      ),
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
    ),
  );
}
