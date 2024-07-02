import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/firebase/firebase_auth_provider.dart';

import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

//import '../l10n/l10n.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.read(appThemeProvider);
    final router = ref.read(routerProvider);
    final firebaseAuth = ref.read(firebaseAuthProvider);
    firebaseAuth.authStateChanges().listen(
      (user) {
        ref.read(currentUserStateProvider.notifier).state = user;
        router.refresh();
      },
    );

    return FluentApp.router(
      title: 'Health Sentry',
      debugShowCheckedModeBanner: false,
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
    );
  }
}
