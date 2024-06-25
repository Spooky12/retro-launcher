import 'dart:async';

import 'package:device_apps/device_apps.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'apps_provider.g.dart';

@riverpod
class Apps extends _$Apps {
  late StreamSubscription<ApplicationEvent> _sub;

  @override
  FutureOr<List<Application>> build() async {
    final apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    _sub = DeviceApps.listenToAppsChanges().listen(_appsChangeListener);
    ref.onDispose(() {
      _sub.cancel();
    });

    return apps.where((app) => app.enabled).toList()..sort(_compareApp);
  }

  Future<void> refreshApps() async {
    final apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    final filteredApps = apps.where((app) => app.enabled).toList()
      ..sort(_compareApp);

    if (state.value != filteredApps) {
      state = AsyncValue.data(filteredApps);
    }
  }

  void _appsChangeListener(ApplicationEvent event) {
    if (state case AsyncData(:final value)) {
      switch (event) {
        case ApplicationEventInstalled(:final application) ||
              ApplicationEventEnabled(:final application):
          state = AsyncValue.data([...value, application]..sort(_compareApp));
        case ApplicationEventUninstalled(:final packageName) ||
              ApplicationEventDisabled(:final packageName):
          state = AsyncValue.data(
            value.where((app) => app.packageName != packageName).toList(),
          );
      }
    }
  }

  int _compareApp(Application a1, Application a2) =>
      a1.appName.compareTo(a2.appName);
}
