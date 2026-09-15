part of 'theme.dart';

class AppTextStyles {
  static const _fontFamily = 'Poppins';

  static TextStyle _baseTextStyle({Color? color}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: AppFontWeights.regular,
      color: color, // Use default or custom color
    );
  }

  /// 32 700
  static TextStyle headline1({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 32, fontWeight: AppFontWeights.bold);
  }

  /// 24 600
  static TextStyle headline2({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 24, fontWeight: AppFontWeights.semiBold);
  }

  /// 22 600
  static TextStyle headline3({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 22, fontWeight: AppFontWeights.semiBold);
  }

  /// 20 600
  static TextStyle headline4({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 20, fontWeight: AppFontWeights.semiBold);
  }

  /// 18 600
  static TextStyle headline5({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 18, fontWeight: AppFontWeights.semiBold);
  }

  /// 16 700
  static TextStyle bodyText1({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 16, fontWeight: AppFontWeights.bold);
  }

  /// 16 600
  static TextStyle bodyText2({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 16, fontWeight: AppFontWeights.semiBold);
  }

  /// 14 700
  static TextStyle subtitle1({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 14, fontWeight: AppFontWeights.bold);
  }

  /// 14 400
  static TextStyle subtitle2({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 14, fontWeight: AppFontWeights.regular);
  }

  /// 12 700
  static TextStyle caption({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 12, fontWeight: AppFontWeights.bold);
  }

  /// 12 600
  static TextStyle caption2({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 12, fontWeight: AppFontWeights.semiBold);
  }

  /// 18 500
  static TextStyle button({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 18, fontWeight: AppFontWeights.medium);
  }

  /// 16 400
  static TextStyle overLine({Color? color}) {
    return _baseTextStyle(
      color: color,
    ).copyWith(fontSize: 16, fontWeight: AppFontWeights.regular);
  }
}
