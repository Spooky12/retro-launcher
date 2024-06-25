import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';

import '../providers/apps_provider.dart';
import '../widgets/app_item.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncApps = ref.watch(appsProvider);

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        ref.read(appsProvider.notifier).refreshApps();
      }
    });

    return Scaffold(
      backgroundColor: switch (Theme.of(context).brightness) {
        Brightness.dark => Colors.black,
        Brightness.light => Colors.white,
      },
      body: switch (asyncApps) {
        AsyncData(:final value) => Apps(value),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        _ => const Center(child: NesHourglassLoadingIndicator()),
      },
    );
  }
}

class Apps extends HookWidget {
  const Apps(this.apps, {super.key});

  final List<Application> apps;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        physics: const ClampingScrollPhysics(),
        overscroll: false,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = NesScrollbar.scrollbarSize;
          final width = constraints.maxWidth - gap;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                child: CustomScrollView(
                  controller: controller,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 12.0,
                          ) +
                          MediaQuery.paddingOf(context),
                      sliver: SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: width / 4,
                          childAspectRatio: 0.90,
                          mainAxisSpacing: 12.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: apps.length,
                        itemBuilder: (_, i) => AppItem(
                          key: ValueKey(apps[i].packageName),
                          app: apps[i],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              NesScrollbar(
                scrollController: controller,
                direction: Axis.vertical,
              ),
            ],
          );
        },
      ),
    );
  }
}
