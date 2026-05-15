// Root: [ChangeNotifierProvider] + [MaterialApp]. Layar pertama [_AppLoader] menunggu [FinanceProvider.isReady].
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/finance_provider.dart';
import 'screens/shell_screen.dart';
import 'widgets/branded_splash.dart';

class UangKyApp extends StatelessWidget {
  const UangKyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider(),
      child: MaterialApp(
        title: 'UangKy',
        debugShowCheckedModeBanner: false,
        theme: buildUangKyTheme(),
        home: const _AppLoader(),
      ),
    );
  }
}

/// Menampilkan loading sampai [FinanceProvider] selesai load dari [StorageService] (hindari race UI).
class _AppLoader extends StatelessWidget {
  const _AppLoader();

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, fin, _) {
        if (!fin.isReady) {
          return const BrandedSplash();
        }
        return const ShellScreen();
      },
    );
  }
}

bool get suggestMobileDownload => kIsWeb;
