/// Centralized Supabase table name constants.
/// All datasources should use these instead of hardcoded strings.
class SupabaseTable {
  // ── Core ──
  static const String profiles = 'profiles';
  static const String group = 'Group';
  static const String members = 'Members';

  // ── Discussion / Feed / Doubt ──
  static const String post = 'Post';
  static const String comment = 'Comment';
  static const String like = 'Like';

  // ── Classroom ──
  static const String course = 'Course';
  static const String module = 'Module';
  static const String classroom = 'Classroom';
  static const String classFolder = 'ClassFolder';
  static const String section = 'Section';
  static const String content = 'Content';

  // ── Events & Live Class ──
  static const String event = 'Event';
  static const String liveClass = 'Event';
  static const String channel = 'Channel';

  // ── Chat ──
  static const String message = 'Message';

  // ── Notifications ──
  static const String notifications = 'Notifications';
  static const String notificationBatches = 'NotificationBatches';

  // ── Challenges ──
  static const String challenges = 'Challenges';
  static const String challengeDays = 'ChallengeDays';
  static const String challengeRegistrations = 'ChallengeRegistrations';
  static const String challengeSubmissions = 'ChallengeSubmissions';
  static const String challengeWinners = 'ChallengeWinners';

  // ── Products & Services ──
  static const String productAndService = 'ProductAndService';

  // ── Jobs ──
  static const String job = 'Job';
  static const String jobApplication = 'JobApplication';

  // ── Group Management ──
  static const String groupInvitation = 'GroupInvitation';
  static const String groupManagerInvitation = 'GroupManagerInvitation';
  static const String groupMemberBlocks = 'GroupMemberBlocks';
  static const String groupMemberLeaves = 'GroupMemberLeaves';
  static const String groupTabSettings = 'GroupTabSettings';
  static const String groupLeaveSettings = 'GroupLeaveSettings';

  // ── Resources ──
  static const String resource = 'Resource';
  static const String resourceCategory = 'ResourceCategory';

  // ── Payments & Subscriptions ──
  static const String supporter = 'Supporter';
  static const String offer = 'Offer';
  static const String promoCode = 'PromoCode';
  static const String packageSubscriptions = 'PackageSubscriptions';
  static const String paymentOrders = 'PaymentOrders';
}
