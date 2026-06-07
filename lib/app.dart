import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// CFPV root application widget.
class CFPVApp extends ConsumerWidget {
  const CFPVApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CFPV',
      debugShowCheckedModeBanner: false,
      theme: CFPVTheme.light,
      routerConfig: router,
    );
  }
}
