class AppConfig {
  final String templatesDir;
  final String snapshotsDir;
  final int monitoringIntervalSeconds;
  final String theme;
  final String locale;
  final bool minimizeToTray;
  final bool launchAtStartup;

  const AppConfig({
    required this.templatesDir,
    required this.snapshotsDir,
    this.monitoringIntervalSeconds = 5,
    this.theme = 'system',
    this.locale = 'system',
    this.minimizeToTray = true,
    this.launchAtStartup = false,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        templatesDir: json['templates_dir'] as String,
        snapshotsDir: json['snapshots_dir'] as String,
        monitoringIntervalSeconds:
            json['monitoring_interval_seconds'] as int? ?? 5,
        theme: json['theme'] as String? ?? 'system',
        locale: json['locale'] as String? ?? 'system',
        minimizeToTray: json['minimize_to_tray'] as bool? ?? true,
        launchAtStartup: json['launch_at_startup'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'version': 1,
        'templates_dir': templatesDir,
        'snapshots_dir': snapshotsDir,
        'monitoring_interval_seconds': monitoringIntervalSeconds,
        'theme': theme,
        'locale': locale,
        'minimize_to_tray': minimizeToTray,
        'launch_at_startup': launchAtStartup,
      };

  AppConfig copyWith({
    String? templatesDir,
    String? snapshotsDir,
    int? monitoringIntervalSeconds,
    String? theme,
    String? locale,
    bool? minimizeToTray,
    bool? launchAtStartup,
  }) =>
      AppConfig(
        templatesDir: templatesDir ?? this.templatesDir,
        snapshotsDir: snapshotsDir ?? this.snapshotsDir,
        monitoringIntervalSeconds:
            monitoringIntervalSeconds ?? this.monitoringIntervalSeconds,
        theme: theme ?? this.theme,
        locale: locale ?? this.locale,
        minimizeToTray: minimizeToTray ?? this.minimizeToTray,
        launchAtStartup: launchAtStartup ?? this.launchAtStartup,
      );
}
