import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_gate.dart';
import '../auth/auth_state.dart';
import '../api/api_client.dart';
import '../config/app_config.dart';
import '../contract/module_context.dart';
import '../contract/module_nav_entry.dart';
import '../contract/mycel_module.dart';
import '../errors/error_reporter.dart';
import '../logging/logger_factory.dart';
import '../storage/secure_storage.dart';
import '../storage/cache_storage.dart';
import '../telemetry/telemetry_observer.dart';
import '../telemetry/telemetry_service.dart';
import '../theme/mycel_theme.dart';
import 'mycel_shell_config.dart';

/// The mobile shell. Equivalent to mycel_core_web's layout chrome.
class MycelShell extends StatefulWidget {
  final String authToken;
  final List<MycelModule> modules;
  final MycelShellConfig? config;

  const MycelShell({
    required this.authToken,
    required this.modules,
    this.config,
    super.key,
  });

  @override
  State<MycelShell> createState() => _MycelShellState();
}

class _MycelShellState extends State<MycelShell> {
  late final AppConfig _appConfig;
  late final AuthState _authState;
  late final ApiClient _apiClient;
  late final SecureStorage _secureStorage;
  late final CacheStorage _cacheStorage;
  late final LoggerFactory _loggerFactory;
  late final ErrorReporter _errorReporter;
  late final TelemetryService _telemetry;

  late final List<ModuleNavEntry> _navEntries;
  int _currentIndex = 0;
  bool _initialized = false;
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final config = widget.config ?? const MycelShellConfig();

    _appConfig = await AppConfig.load();
    _authState = AuthState(token: widget.authToken);
    String apiBaseUrl;
    if (config.apiBaseUrl != null) {
      apiBaseUrl = config.apiBaseUrl!;
    } else {
      try {
        apiBaseUrl = _appConfig.getServiceUrl('api');
      } on ConfigError {
        apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
      }
    }
    _apiClient = ApiClient(
      baseUrl: apiBaseUrl,
      authState: _authState,
    );
    _secureStorage = SecureStorage();
    _cacheStorage = CacheStorage();
    _loggerFactory = LoggerFactory();
    _errorReporter = ErrorReporter();
    _telemetry = TelemetryService(enabled: config.telemetryEnabled);

    final moduleContext = ModuleContext(
      auth: _authState,
      apiClient: _apiClient,
      config: _appConfig,
      loggerFactory: _loggerFactory,
      errorReporter: _errorReporter,
      telemetry: _telemetry,
    );
    for (final module in widget.modules) {
      await module.initialize(moduleContext);
    }

    _navEntries = widget.modules
        .expand((m) => m.navEntries)
        .where((e) => e.showInNav)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    setState(() => _initialized = true);
  }

  // ════════════════════════════════════════════════════════════
  // SHELL SCAFFOLD — empty-modules mode
  // ════════════════════════════════════════════════════════════

  Widget _buildShellScaffold() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // ── Header ──
          _ShellHeader(isDark: isDark),
          // ── Body ──
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const _HomePage(),
                const _PlaceholderPage(
                  icon: Icons.folder_rounded,
                  title: 'Projects',
                  subtitle: 'Your projects will appear here',
                  actionLabel: 'Create Project',
                ),
                const _PlaceholderPage(
                  icon: Icons.check_circle_rounded,
                  title: 'Tasks',
                  subtitle: 'Your tasks will appear here',
                  actionLabel: 'Create Task',
                ),
                _SettingsPage(
                  themeMode: _themeMode,
                  onThemeModeChanged: _setThemeMode,
                ),
              ],
            ),
          ),
          // ── Bottom nav ──
          _BottomNav(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiClient.dispose();
    _telemetry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        theme: MycelTheme.light(),
        darkTheme: MycelTheme.dark(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      theme: MycelTheme.light(),
      darkTheme: MycelTheme.dark(),
      themeMode: _themeMode,
      home: MultiProvider(
        providers: [
          Provider<AppConfig>.value(value: _appConfig),
          ChangeNotifierProvider<AuthState>.value(value: _authState),
          Provider<ApiClient>.value(value: _apiClient),
          Provider<SecureStorage>.value(value: _secureStorage),
          Provider<CacheStorage>.value(value: _cacheStorage),
          Provider<LoggerFactory>.value(value: _loggerFactory),
          Provider<ErrorReporter>.value(value: _errorReporter),
          Provider<TelemetryService>.value(value: _telemetry),
          ...widget.modules.expand((m) => m.providers),
        ],
        child: AuthGate(
          authState: _authState,
          onAuthExpired: () => Navigator.of(context).pop(),
          child: _navEntries.isEmpty
              ? _buildShellScaffold()
              : Scaffold(
                  body: IndexedStack(
                    index: _currentIndex,
                    children: _navEntries.map((entry) {
                      return Navigator(
                        key: ValueKey(entry.id),
                        observers: [
                          if (_telemetry.enabled) TelemetryObserver(_telemetry),
                        ],
                        onGenerateRoute: (_) => MaterialPageRoute(
                          builder: (_) => entry.rootBuilder(),
                        ),
                      );
                    }).toList(),
                  ),
                  bottomNavigationBar: _navEntries.length > 1
                      ? BottomNavigationBar(
                          currentIndex: _currentIndex,
                          onTap: (i) => setState(() => _currentIndex = i),
                          type: BottomNavigationBarType.fixed,
                          items: _navEntries
                              .map((e) => BottomNavigationBarItem(
                                    icon: Icon(e.icon),
                                    label: e.label,
                                  ))
                              .toList(),
                        )
                      : null,
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════

class _ShellHeader extends StatelessWidget {
  final bool isDark;
  const _ShellHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: cs.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 8, 10),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi, User',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'user@mycel.dev',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Badge(
                  smallSize: 7,
                  backgroundColor: const Color(0xFFEF4444),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: cs.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: cs.onSurfaceVariant,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BOTTOM NAV
// ═══════════════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.folder_outlined, Icons.folder_rounded, 'Portfolio'),
    (Icons.check_circle_outline, Icons.check_circle_rounded, 'Tasks'),
    (Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _items.length; i++)
                _buildItem(context, i, cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, ColorScheme cs) {
    final isActive = index == currentIndex;
    final item = _items[index];
    final color = isActive ? cs.primary : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.$2 : item.$1,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              item.$3,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HOME TAB
// ═══════════════════════════════════════════════════════════════

/// Shared card decoration — visible borders in dark mode, subtle shadow in light.
BoxDecoration _cardDecor({
  required Color color,
  required bool isDark,
  double radius = 20,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5)
        : null,
    boxShadow: [
      if (!isDark)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 3),
        ),
    ],
  );
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // ── Balance card (like reference) ──
        Container(
          padding: const EdgeInsets.all(24),
          decoration: _cardDecor(color: cardColor, isDark: isDark),
          child: Column(
            children: [
              // Mycel logo icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.hub_rounded, size: 26, color: cs.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Mycel',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Build-time composed foundation\nfor modern applications.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Getting started section ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecor(color: cardColor, isDark: isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Getting started',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s what you need to set up your workspace.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              // Progress
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pie_chart_rounded, size: 18, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '1/4 completed',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Checklist items
              _ChecklistItem(
                icon: Icons.check_circle_rounded,
                title: 'Create your account',
                done: true,
                isDark: isDark,
              ),
              _ChecklistItem(
                icon: Icons.radio_button_unchecked,
                title: 'Configure a project',
                done: false,
                isDark: isDark,
              ),
              _ChecklistItem(
                icon: Icons.radio_button_unchecked,
                title: 'Add team members',
                done: false,
                isDark: isDark,
              ),
              _ChecklistItem(
                icon: Icons.radio_button_unchecked,
                title: 'Register a module',
                done: false,
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Overview stats ──
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _buildStatRow(theme, cs, isDark, cardColor),

        const SizedBox(height: 24),

        // ── Quick actions ──
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'View All',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ..._buildActionItems(theme, cs, isDark, cardColor),

        // ── Shell info ──
        const SizedBox(height: 28),
        Center(
          child: Text(
            'Mobile Shell v0.1.0  ·  No modules registered',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(ThemeData theme, ColorScheme cs, bool isDark, Color cardColor) {
    const stats = [
      ('12', 'Projects', Color(0xFF0D9488)),
      ('48', 'Completed', Color(0xFF3B82F6)),
      ('99%', 'Uptime', Color(0xFF22C55E)),
      ('8', 'Members', Color(0xFF8B5CF6)),
    ];

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: _cardDecor(color: cardColor, isDark: isDark, radius: 16),
              child: Column(
                children: [
                  Text(
                    stats[i].$1,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: stats[i].$3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stats[i].$2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActionItems(ThemeData theme, ColorScheme cs, bool isDark, Color cardColor) {
    const items = [
      (Icons.dashboard_rounded, 'Dashboard', 'Overview and key metrics', Color(0xFF0D9488)),
      (Icons.folder_rounded, 'Projects', 'Manage and track progress', Color(0xFF3B82F6)),
      (Icons.check_circle_rounded, 'Tasks', 'Create and assign tasks', Color(0xFF8B5CF6)),
      (Icons.settings_rounded, 'Settings', 'Configure your workspace', Color(0xFFD97706)),
    ];

    return [
      for (int i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: _cardDecor(color: cardColor, isDark: isDark, radius: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: items[i].$4.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(items[i].$1, size: 20, color: items[i].$4),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[i].$2,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      items[i].$3,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ],
    ];
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool done;
  final bool isDark;

  const _ChecklistItem({
    required this.icon,
    required this.title,
    required this.done,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: done ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: done ? cs.onSurface : cs.onSurfaceVariant,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PLACEHOLDER TAB (Projects / Tasks)
// ═══════════════════════════════════════════════════════════════

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;

  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 36, color: cs.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(actionLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS TAB
// ═══════════════════════════════════════════════════════════════

class _SettingsPage extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const _SettingsPage({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _sectionLabel(theme, 'ACCOUNT'),
        const SizedBox(height: 8),
        _SettingsGroup(cardColor: cardColor, isDark: isDark, children: const [
          _SettingsTile(icon: Icons.person_outline, title: 'Profile', subtitle: 'Name, email, avatar', iconColor: Color(0xFF0D9488)),
          _SettingsTile(icon: Icons.shield_outlined, title: 'Security', subtitle: 'Password, biometrics', iconColor: Color(0xFF0D9488)),
        ]),

        const SizedBox(height: 24),
        _sectionLabel(theme, 'PREFERENCES'),
        const SizedBox(height: 8),
        _SettingsGroup(cardColor: cardColor, isDark: isDark, children: [
          const _SettingsTile(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Push, email, in-app', iconColor: Color(0xFFD97706)),
          _ThemeModeTile(themeMode: themeMode, onChanged: onThemeModeChanged, isDark: isDark),
          const _SettingsTile(icon: Icons.language, title: 'Language', subtitle: 'English (US)', iconColor: Color(0xFF3B82F6)),
        ]),

        const SizedBox(height: 24),
        _sectionLabel(theme, 'ABOUT'),
        const SizedBox(height: 8),
        _SettingsGroup(cardColor: cardColor, isDark: isDark, children: const [
          _SettingsTile(icon: Icons.info_outline, title: 'About Mycel', subtitle: 'Mobile Shell v0.1.0', iconColor: Color(0xFF6B7280)),
          _SettingsTile(icon: Icons.description_outlined, title: 'Licenses', subtitle: 'Open-source licenses', iconColor: Color(0xFF6B7280)),
        ]),
      ],
    );
  }

  static Widget _sectionLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final Color cardColor;
  final bool isDark;

  const _SettingsGroup({
    required this.children,
    required this.cardColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecor(color: cardColor, isDark: isDark, radius: 16),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 60,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;
  final bool isDark;

  const _ThemeModeTile({
    required this.themeMode,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const iconColor = Color(0xFF8B5CF6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.palette_outlined, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Text('Appearance', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 14),
          // Segmented selector
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _modeChip(context, ThemeMode.light, Icons.light_mode_rounded, 'Light'),
                _modeChip(context, ThemeMode.system, Icons.phone_iphone_rounded, 'System'),
                _modeChip(context, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip(BuildContext context, ThemeMode mode, IconData icon, String label) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
