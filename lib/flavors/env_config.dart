
class EnvConfig {
  final String appName;
  final String baseUrlAuthen;
  final String baseUrlUtility;
  final String baseUrlGraphQLCore;
  final bool shouldCollectCrashLog;

  // late final Logger logger;

  EnvConfig({
    required this.appName,
    required this.baseUrlAuthen,
    required this.baseUrlUtility,
    required this.baseUrlGraphQLCore,
    this.shouldCollectCrashLog = false,
  }) {
    // logger = Logger(
    //   printer: PrettyPrinter(
    //       methodCount: AppValues.loggerMethodCount,
    //       // number of method calls to be displayed
    //       errorMethodCount: AppValues.loggerErrorMethodCount,
    //       // number of method calls if stacktrace is provided
    //       lineLength: AppValues.loggerLineLength,
    //       // width of the output
    //       colors: true,
    //       // Colorful log messages
    //       printEmojis: true,
    //       // Print an emoji for each log message
    //       printTime: false // Should each log print contain a timestamp
    //       ),
    // );
  }
}
