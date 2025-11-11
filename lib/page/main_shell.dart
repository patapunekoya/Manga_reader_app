import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

// Các trang thật
import 'home_shell_page.dart';
import 'search_shell_page.dart';
import 'library_shell_page.dart';

/// ======================================================================
/// File: page/main_shell.dart
/// Mục đích:
///   - Đóng vai trò “App shell” tầng UI cho 3 tab chính: Home / Search / Library.
///   - Quản lý chuyển tab bằng PageView + BottomNavigationBar.
///   - Tối ưu hiệu năng: chỉ render trang đang active (lazy), giữ state bằng keepAlive.
///
/// Kiến trúc & Dòng chảy:
///   - Người dùng vuốt trái/phải hoặc bấm icon bottom nav.
///   - MainShell điều khiển PageController -> PageView animate/jump đến trang.
///   - Mỗi trang con được bọc bởi _LazyPage:
///       • active == true  → dựng widget thật (HomeShellPage / SearchShellPage / LibraryShellPage)
///       • active == false → trả về SizedBox.expand() (placeholder rỗng, không tốn tài nguyên)
///
/// Quy ước:
///   - Không pre-cache trang lân cận (allowImplicitScrolling=false, cacheExtent mặc định).
///   - Animation thời gian phụ thuộc khoảng cách tab để cảm giác “hợp lý”.
///   - Bottom nav là nguồn sự thật cho selectedIndex hiển thị.
/// ======================================================================
class MainShell extends StatefulWidget {
  /// Tab muốn hiển thị khi vào shell (0=Home, 1=Search, 2=Library).
  final int currentIndex;
  const MainShell({super.key, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // PageController điều khiển PageView
  late final PageController _controller;
  // Chỉ số tab đang hiển thị (đồng bộ với PageView.onPageChanged)
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.currentIndex;
    _controller = PageController(initialPage: widget.currentIndex, keepPage: true);
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi parent yêu cầu chuyển tab (ví dụ: điều hướng /home, /search, /library)
    // và khác tab hiện tại, thực hiện animate.
    if (oldWidget.currentIndex != widget.currentIndex && _activeIndex != widget.currentIndex) {
      _jumpTo(widget.currentIndex);
    }
  }

  /// Chuyển đến tab [index] với animation tùy theo khoảng cách.
  /// - distance = |index - _activeIndex|
  /// - ms = max(180, 140 * distance): nhảy xa thì nhanh hơn nhưng vẫn “lướt”.
  Future<void> _jumpTo(int index) async {
    if (index == _activeIndex) return;
    final distance = (index - _activeIndex).abs();
    // Nhanh hơn khi nhảy xa, nhưng vẫn có cảm giác "lướt"
    final ms = math.max(180, 140 * distance);
    await _controller.animateToPage(
      index,
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Bọc mỗi trang bằng LazyPage:
  // - active == true: render trang thật
  // - active == false: trả về SizedBox.expand() (placeholder rỗng, rẻ)
  Widget _buildLazy({required int index, required Widget child}) {
    return _LazyPage(
      key: PageStorageKey('tab-$index'),
      active: _activeIndex == index,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền thống nhất toàn app
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _controller,
        itemCount: 3,
        physics: const BouncingScrollPhysics(), // vẫn cho vuốt mượt
        allowImplicitScrolling: false,          // đừng render trang cạnh
        padEnds: false,
        // cacheExtent 0 để không pre-cache trang lân cận
        onPageChanged: (i) {
          // Cập nhật chỉ số active khi user vuốt
          setState(() => _activeIndex = i);
        },
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildLazy(index: 0, child: const HomeShellPage());
            case 1:
              return _buildLazy(index: 1, child: const SearchShellPage());
            case 2:
            default:
              return _buildLazy(index: 2, child: const LibraryShellPage());
          }
        },
      ),
      // Thanh điều hướng đáy: là nguồn event chuyển tab khi người dùng bấm icon
      bottomNavigationBar: _BottomNav(
        currentIndex: _activeIndex,
        onTap: (i) => _jumpTo(i),
      ),
    );
  }
}

/// Trang "lười": chỉ dựng child khi active. Còn lại là placeholder rỗng.
/// Vẫn giữ state nội bộ nhờ AutomaticKeepAliveClientMixin.
class _LazyPage extends StatefulWidget {
  final bool active;
  final Widget child;

  const _LazyPage({super.key, required this.active, required this.child});

  @override
  State<_LazyPage> createState() => _LazyPageState();
}

class _LazyPageState extends State<_LazyPage> with AutomaticKeepAliveClientMixin {
  // Luôn giữ state của trang kể cả khi off-screen
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Khi không active: không dựng UI nặng, chỉ trả placeholder chiếm chỗ.
    return widget.active ? widget.child : const SizedBox.expand();
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 62,
      backgroundColor: const Color(0xFF111114),
      indicatorColor: const Color(0xFF262633),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Khám phá',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: 'Tìm kiếm',
        ),
        NavigationDestination(
          icon: Icon(Icons.collections_bookmark_outlined),
          selectedIcon: Icon(Icons.collections_bookmark),
          label: 'Thư viện',
        ),
      ],
    );
  }
}
