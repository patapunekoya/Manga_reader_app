import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

// Các trang thật
import 'home_shell_page.dart';
import 'search_shell_page.dart';
import 'library_shell_page.dart';

/// MainShell: chứa PageView + BottomNav.
/// - Vuốt trái/phải bình thường giữa 3 tab.
/// - Khi bấm icon, animate trực tiếp tới tab mục tiêu (duration theo khoảng cách).
/// - Trang KHÔNG active sẽ render placeholder rỗng để không tốn tài nguyên.
class MainShell extends StatefulWidget {
  final int currentIndex;
  const MainShell({super.key, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final PageController _controller;
  late int _activeIndex; // tab đang hiển thị

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.currentIndex;
    _controller = PageController(initialPage: widget.currentIndex, keepPage: true);
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && _activeIndex != widget.currentIndex) {
      _jumpTo(widget.currentIndex);
    }
  }

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
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _controller,
        itemCount: 3,
        physics: const BouncingScrollPhysics(), // vẫn cho vuốt mượt
        allowImplicitScrolling: false,          // đừng render trang cạnh
        padEnds: false,
        // cacheExtent 0 để không pre-cache trang lân cận
        onPageChanged: (i) {
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
