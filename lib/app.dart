// lib/app.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:auth/auth.dart'; // Import Auth Module

import 'routes/app_router.dart';
import 'theme/app_theme.dart';
// Note: Cần đảm bảo file theme/colors.dart có thể được gọi nếu dùng theme/app_theme.dart

class MangaReaderApp extends StatelessWidget {
  final AppRouter router;

  const MangaReaderApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: AuthStatusBloc must be provided at the highest level possible (Root)
    return BlocProvider(
      // Lấy Singleton instance của AuthStatusBloc từ GetIt (đã đăng ký ở bootstrap)
      create: (context) => GetIt.instance<AuthStatusBloc>(), 
      child: _GlobalRedirectWrapper(router: router),
    );
  }
}

// Widget mới để xử lý logic chuyển hướng dựa trên trạng thái BLoC
class _GlobalRedirectWrapper extends StatelessWidget {
  final AppRouter router;

  const _GlobalRedirectWrapper({required this.router});

  // HÀM TIỆN ÍCH MỚI: Lấy đường dẫn hiện tại (location)
  String _getCurrentLocation() {
    // Truy cập RouteInformationProvider để lấy location an toàn
    final routeInformation = router.config.routeInformationProvider.value;
    return routeInformation.location ?? '/';
  }

  @override
  Widget build(BuildContext context) {
    // 2. BlocListener: Lắng nghe trạng thái và kích hoạt chuyển hướng
    return BlocListener<AuthStatusBloc, AuthStatusState>(
      listener: (context, state) {
        // Lấy đường dẫn hiện tại một cách an toàn
        final currentPath = _getCurrentLocation(); 
        
        final isLibraryProtected = currentPath.startsWith('/library');
        
        // Logic redirect chính
        if (state.status == AuthStatus.unauthenticated) {
            // Khi log out, chuyển về Login (nếu không ở Login/Register)
            if (!currentPath.startsWith('/login') && !currentPath.startsWith('/register')) {
                router.config.go('/login');
            }
        } else if (state.status == AuthStatus.authenticated) {
            // Khi login thành công, chuyển về Home (hoặc Library nếu đó là trang bị chặn)
            final targetPath = isLibraryProtected ? currentPath : '/home';
            router.config.go(targetPath);
        }
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Manga Reader',
        theme: buildAppTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.dark,
        routerConfig: router.config,
      ),
    );
  }
}