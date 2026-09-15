part of 'theme.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(primary: AppColors.primaryOrange),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryOrange,
      surface: AppColors.darkBgContainer,
      onPrimary: AppColors.black,
      onSurface: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBgContainer,
      foregroundColor: AppColors.white,
    ),
  );
}
