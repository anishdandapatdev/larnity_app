import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env.staging')
abstract class AppEnv {
  @EnviedField(varName: 'GOOGLE_CLIENT_ID')
static const String googleClientId=_AppEnv.googleClientId;  

@EnviedField(varName: 'GOOGLE_SERVER_ID')
static const String googleServerId=_AppEnv.googleServerId;

@EnviedField(varName: 'SUPABASE_BASE_URL')
static const String supabaseBaseUrl=_AppEnv.supabaseBaseUrl;
@EnviedField(varName: 'SUPABASE_PUBLISHABLE_KEY')
static const String supabasePublishableKey=_AppEnv.supabasePublishableKey;

  }