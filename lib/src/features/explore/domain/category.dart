import 'package:hugeicons/styles/stroke_rounded.dart';

class Category {
  final String name;
  final List<List<dynamic>> icon;

  Category({required this.name, required this.icon});
}

List<Category> categories = [
  Category(name: 'All', icon: HugeIconsStrokeRounded.grid),
  Category(name: 'Fitness', icon: HugeIconsStrokeRounded.dumbbell02),

  Category(name: 'Business', icon: HugeIconsStrokeRounded.briefcase09),

  Category(name: 'Personal Development', icon: HugeIconsStrokeRounded.golfHole),

  Category(name: 'Lifestyle & Habits', icon: HugeIconsStrokeRounded.shaka03),

  Category(
    name: 'Technology & Digital Skills',
    icon: HugeIconsStrokeRounded.global,
  ),

  Category(name: 'Relationships', icon: HugeIconsStrokeRounded.shaka01),

  Category(name: 'Education', icon: HugeIconsStrokeRounded.notebook01),

  Category(name: 'Health & Wellness', icon: HugeIconsStrokeRounded.health),

  Category(name: 'Career', icon: HugeIconsStrokeRounded.userSearch01),

  Category(name: 'Finance', icon: HugeIconsStrokeRounded.piggyBank),

  Category(name: 'Parenting & Family', icon: HugeIconsStrokeRounded.home03),

  Category(name: 'Spirituality', icon: HugeIconsStrokeRounded.church),

  Category(
    name: 'Leadership & Management',
    icon: HugeIconsStrokeRounded.userShield01,
  ),

  Category(name: 'Entrepreneurship', icon: HugeIconsStrokeRounded.city01),

  Category(
    name: 'Mental Health & Mindfulness',
    icon: HugeIconsStrokeRounded.brain,
  ),

  Category(
    name: 'Communication & Public Speaking',
    icon: HugeIconsStrokeRounded.megaphone01,
  ),

  Category(name: 'Creative Arts', icon: HugeIconsStrokeRounded.brush),

  Category(
    name: 'Language & Communication',
    icon: HugeIconsStrokeRounded.globe02,
  ),

  Category(
    name: 'Productivity & Time Management',
    icon: HugeIconsStrokeRounded.clock02,
  ),

  Category(
    name: 'Legal & Compliance',
    icon: HugeIconsStrokeRounded.justiceScale01,
  ),

  Category(name: 'Sales & Marketing', icon: HugeIconsStrokeRounded.analyticsUp),
];