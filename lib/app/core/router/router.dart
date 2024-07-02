import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_sentry/app/core/utils/connectivity_state.dart';
import 'package:health_sentry/app/features/accounts/view/account_view.dart';
import 'package:health_sentry/app/features/charts/view/charts_view.dart';
import 'package:health_sentry/app/features/records/view/records_view.dart';
import 'package:health_sentry/app/features/settings/view/settings_view.dart';
import 'package:health_sentry/app/features/signin/view/signin_view.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../features/main/view/main_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');

///
/// for getting routers that are present in the app
///
final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: SignInView.routeName,
      navigatorKey: _rootNavigatorKey,
      redirect: (context, state) {
        final bool loggedIn = FirebaseAuth.instance.currentUser != null;
        final bool loggingIn = state.matchedLocation == SignInView.routeName;
        if (!loggedIn) return SignInView.routeName;
        if (loggingIn) return MainView.routeName;
        return null;
      },
      routes: [
        GoRoute(
          path: SignInView.routeName,
          builder: (context, state) => const SignInView(),
        ),
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainNavigationPage(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  name: MainView.routeName,
                  path: MainView.routeName,
                  builder: (context, state) => const MainView(),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  name: ChartsView.routeName,
                  path: ChartsView.routeName,
                  builder: (context, state) => const ChartsView(),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  name: RecordsView.routeName,
                  path: RecordsView.routeName,
                  builder: (context, state) => const RecordsView(),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  name: AccountView.routeName,
                  path: AccountView.routeName,
                  builder: (context, state) => const AccountView(),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  name: SettingsView.routeName,
                  path: SettingsView.routeName,
                  builder: (context, state) => const SettingsView(),
                )
              ]),
            ])
      ],
    );
  },
);

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  late final List<NavigationPaneItem> items = [
    PaneItem(
      key: const ValueKey(MainView.routeName),
      icon: const Icon(FluentIcons.map_pin),
      title: const Text('Jones Map'),
      body: const SizedBox.shrink(),
    ),
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey(ChartsView.routeName),
      icon: const Icon(FluentIcons.health_solid),
      title: const Text('Statistics & Graphs'),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey(RecordsView.routeName),
      icon: const Icon(FluentIcons.database_view),
      title: const Text('Data Records'),
      body: const SizedBox.shrink(),
    ),
  ].map<NavigationPaneItem>((e) {
    PaneItem buildPaneItem(PaneItem item) {
      return PaneItem(
          key: item.key,
          icon: item.icon,
          title: item.title,
          body: item.body,
          onTap: () {
            final path = (item.key as ValueKey).value;
            if (GoRouterState.of(context).uri.toString() != path) {
              // context.go(path);
              context.goNamed(path);
            }
            item.onTap?.call();
          });
    }

    if (e is PaneItemSeparator) return e;
    return buildPaneItem(e as PaneItem);
  }).toList();

  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey(AccountView.routeName),
      icon: const Icon(FluentIcons.account_management),
      title: const Text('Account'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != AccountView.routeName) {
          context.go(AccountView.routeName);
        }
      },
    ),
    PaneItem(
      key: const ValueKey(SettingsView.routeName),
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() !=
            SettingsView.routeName) {
          context.go(SettingsView.routeName);
        }
      },
    ),
  ];
  late StreamSubscription<InternetConnectionStatus> connectionListener;
  @override
  void initState() {
    super.initState();
    connectionListener = InternetConnectionChecker().onStatusChange.listen(
      (status) {
        ref.read(connectivityStateProvider.notifier).state = status;
      },
    );
  }

  @override
  void dispose() {
    connectionListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityStatus = ref.watch(connectivityStateProvider);
    return NavigationView(
      paneBodyBuilder: (item, body) {
        final name =
            item?.key is ValueKey ? (item!.key as ValueKey).value : null;
        return FocusTraversalGroup(
            key: ValueKey('body$name'),
            child: Builder(
              builder: (context) {
                switch (connectivityStatus) {
                  case InternetConnectionStatus.connected:
                    return widget.navigationShell;
                  case InternetConnectionStatus.disconnected:
                    return Stack(
                      children: [
                        widget.navigationShell,
                        const Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: SizedBox(
                            height: 20,
                            child: ColoredBox(
                              color: Colors.errorPrimaryColor,
                              child: Center(
                                child: Text(
                                  "No internet connection",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                }
              },
            ));
      },
      pane: NavigationPane(
        selected: widget.navigationShell.currentIndex,
        displayMode: PaneDisplayMode.compact,
        items: items,
        footerItems: footerItems,
      ),
    );
  }
}
