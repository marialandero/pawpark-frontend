import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0896c7),
      surfaceTint: Color(0xff1c6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc3e7ff),
      onPrimaryContainer: Color(0xff004c69),
      secondary: Color(0xffb21f3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdad9),
      onSecondaryContainer: Color(0xff733336),
      tertiary: Color(0xff099f64),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffa8f2ce),
      onTertiaryContainer: Color(0xff005138),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff181c1f),
      onSurfaceVariant: Color(0xff41484d),
      outline: Color(0xff71787d),
      outlineVariant: Color(0xffc0c7cd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8fcef3),
      primaryFixed: Color(0xffc3e7ff),
      onPrimaryFixed: Color(0xff001e2c),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff004c69),
      secondaryFixed: Color(0xffffdad9),
      onSecondaryFixed: Color(0xff3b080e),
      secondaryFixedDim: Color(0xffffb3b3),
      onSecondaryFixedVariant: Color(0xffd9803b),
      tertiaryFixed: Color(0xffa8f2ce),
      onTertiaryFixed: Color(0xff002114),
      tertiaryFixedDim: Color(0xff8dd5b3),
      onTertiaryFixedVariant: Color(0xff005138),
      surfaceDim: Color(0xffd6dadf),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffeaeef2),
      surfaceContainerHigh: Color(0xffe5e8ed),
      surfaceContainerHighest: Color(0xffdfe3e7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0e86af),
      surfaceTint: Color(0xff1c6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff307495),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff811a32),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa1585a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003f2a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff317a5c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff0d1215),
      onSurfaceVariant: Color(0xff30373c),
      outline: Color(0xff4c5359),
      outlineVariant: Color(0xff676e73),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8fcef3),
      primaryFixed: Color(0xff307495),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff085b7b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffa1585a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff844043),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff317a5c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff116045),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc3c7cb),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffe5e8ed),
      surfaceContainerHigh: Color(0xffd9dde1),
      surfaceContainerHighest: Color(0xffced2d6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff157d9f),
      surfaceTint: Color(0xff1c6585),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004f6c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff591422),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff763538),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003322),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00543a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff262d32),
      outlineVariant: Color(0xff434a4f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff8fcef3),
      primaryFixed: Color(0xff004f6c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00374d),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff763538),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff591f23),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff00543a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003b28),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb5b9bd),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffedf1f5),
      surfaceContainer: Color(0xffdfe3e7),
      surfaceContainerHigh: Color(0xffd1d5d9),
      surfaceContainerHighest: Color(0xffc3c7cb),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff44b2fa),
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff03181e),
      primaryContainer: Color(0xff004c69),
      onPrimaryContainer: Color(0xffc3e7ff),
      secondary: Color(0xff98263b),
      onSecondary: Color(0xff561d21),
      secondaryContainer: Color(0xff733336),
      onSecondaryContainer: Color(0xffffdad9),
      tertiary: Color(0xff8dd5b3),
      onTertiary: Color(0xff003826),
      tertiaryContainer: Color(0xff005138),
      onTertiaryContainer: Color(0xffa8f2ce),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffe8665b),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffdfe3e7),
      onSurfaceVariant: Color(0xffc0c7cd),
      outline: Color(0xff8b9297),
      outlineVariant: Color(0xff41484d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff1c6585),
      primaryFixed: Color(0xffc3e7ff),
      onPrimaryFixed: Color(0xff001e2c),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff004c69),
      secondaryFixed: Color(0xffffdad9),
      onSecondaryFixed: Color(0xff3b080e),
      secondaryFixedDim: Color(0xffffb3b3),
      onSecondaryFixedVariant: Color(0xffeb985d),
      tertiaryFixed: Color(0xffa8f2ce),
      onTertiaryFixed: Color(0xff002114),
      tertiaryFixedDim: Color(0xff8dd5b3),
      onTertiaryFixedVariant: Color(0xff005138),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff353a3d),
      surfaceContainerLowest: Color(0xff0a0f12),
      surfaceContainerLow: Color(0xff181c1f),
      surfaceContainer: Color(0xff1c2023),
      surfaceContainerHigh: Color(0xff262b2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb5e2ff),
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff00293a),
      primaryContainer: Color(0xff5898bb),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd1d1),
      onSecondary: Color(0xff481217),
      secondaryContainer: Color(0xffcb7a7c),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffa2ecc8),
      onTertiary: Color(0xff002c1d),
      tertiaryContainer: Color(0xff579e7f),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd6dde3),
      outline: Color(0xffacb3b9),
      outlineVariant: Color(0xff8a9197),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff004e6a),
      primaryFixed: Color(0xffc3e7ff),
      onPrimaryFixed: Color(0xff00131e),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff003b51),
      secondaryFixed: Color(0xffffdad9),
      onSecondaryFixed: Color(0xff2c0105),
      secondaryFixedDim: Color(0xffffb3b3),
      onSecondaryFixedVariant: Color(0xff5e2326),
      tertiaryFixed: Color(0xffa8f2ce),
      onTertiaryFixed: Color(0xff00150c),
      tertiaryFixedDim: Color(0xff8dd5b3),
      onTertiaryFixedVariant: Color(0xff003f2a),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff404549),
      surfaceContainerLowest: Color(0xff04080b),
      surfaceContainerLow: Color(0xff1a1e21),
      surfaceContainer: Color(0xff24282c),
      surfaceContainerHigh: Color(0xff2e3337),
      surfaceContainerHighest: Color(0xff3a3e42),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe1f2ff),
      surfaceTint: Color(0xff8fcef3),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8bcaef),
      onPrimaryContainer: Color(0xff000d15),
      secondary: Color(0xffffeceb),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffadae),
      onSecondaryContainer: Color(0xff220003),
      tertiary: Color(0xffb9ffdc),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff89d1af),
      onTertiaryContainer: Color(0xff000e07),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeaf1f7),
      outlineVariant: Color(0xffbcc3c9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff004e6a),
      primaryFixed: Color(0xffc3e7ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8fcef3),
      onPrimaryFixedVariant: Color(0xff00131e),
      secondaryFixed: Color(0xffffdad9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb3b3),
      onSecondaryFixedVariant: Color(0xff2c0105),
      tertiaryFixed: Color(0xffa8f2ce),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff8dd5b3),
      onTertiaryFixedVariant: Color(0xff00150c),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff4c5154),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1c2023),
      surfaceContainer: Color(0xff2c3134),
      surfaceContainerHigh: Color(0xff373c3f),
      surfaceContainerHighest: Color(0xff43474b),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xff166ea6),
    value: Color(0xff166ea6),
    light: ColorFamily(
      color: Color(0xff2e628c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcde5ff),
      onColorContainer: Color(0xff0b4a72),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff2e628c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcde5ff),
      onColorContainer: Color(0xff0b4a72),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff2e628c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcde5ff),
      onColorContainer: Color(0xff0b4a72),
    ),
    dark: ColorFamily(
      color: Color(0xff9acbfa),
      onColor: Color(0xff003352),
      colorContainer: Color(0xff0b4a72),
      onColorContainer: Color(0xffcde5ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff9acbfa),
      onColor: Color(0xff003352),
      colorContainer: Color(0xff0b4a72),
      onColorContainer: Color(0xffcde5ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff9acbfa),
      onColor: Color(0xff003352),
      colorContainer: Color(0xff0b4a72),
      onColorContainer: Color(0xffcde5ff),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    customColor1,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
