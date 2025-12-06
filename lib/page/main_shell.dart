import 'dart:math' as math;
import 'package:flutter/material.dart';

// 1. Import Core để lấy AppColors
import 'package:core/core.dart'; 

// 2. Import các trang Shell từ Module
import 'package:home/presentation/page/home_shell_page.dart';
import 'package:catalog/presentation/pages/search_shell_page.dart';
import 'package:library_manga/presentation/pages/library_shell_page.dart';
import 'package:auth/presentation/pages/profile_shell_page.dart';

class MainShell extends StatefulWidget {
  final int currentIndex;
  const MainShell({super.key, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final PageController _controller;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.currentIndex;
    _controller = PageController(initialPage: widget.currentIndex, keepPage: true);
    print("🚀 MainShell INIT - ActiveIndex: $_activeIndex"); // Log để kiểm tra xem màn hình có được build không
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
      
      // Giữ footer cố định, không bị đẩy lên khi bàn phím hiện
      resizeToAvoidBottomInset: false, 
      
      body: PageView.builder(
        controller: _controller,
        itemCount: 4, 
        physics: const BouncingScrollPhysics(),
        allowImplicitScrolling: false, // Tắt pre-cache để tiết kiệm RAM
        onPageChanged: (i) {
          setState(() => _activeIndex = i);
        },
        itemBuilder: (context, index) {
          switch (index) {
            case 0: return _buildLazy(index: 0, child: const HomeShellPage());
            case 1: return _buildLazy(index: 1, child: const SearchShellPage());
            case 2: return _buildLazy(index: 2, child: const LibraryShellPage());
            case 3: return _buildLazy(index: 3, child: const ProfileShellPage());
            default: return const SizedBox.shrink(); 
          }
        },
      ),
      
      // === PHẦN FOOTER ĐÃ SỬA ===
      bottomNavigationBar: _BottomNav(
        currentIndex: _activeIndex,
        onTap: (i) => _jumpTo(i),
      ),
    );
  }
}

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
    return widget.active ? widget.child : const SizedBox.expand();
  }
}

// === WIDGET FOOTER MỚI (Sử dụng BottomNavigationBar thay vì NavigationBar) ===
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Wrap trong Theme để đảm bảo màu nền Canvas chuẩn cho BottomNav
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xFF111114), // Màu nền của Footer
      ),
      child: BottomNavigationBar(
        // QUAN TRỌNG: Type.fixed để hiển thị đủ 4 item mà không bị hiệu ứng shifting
        type: BottomNavigationBarType.fixed,
        
        backgroundColor: const Color(0xFF111114),
        elevation: 8, // Đổ bóng nhẹ để tách biệt với body
        
        currentIndex: currentIndex,
        onTap: onTap,
        
        // Cấu hình màu sắc rõ ràng
        selectedItemColor: const Color(0xFF7C4DFF), // Màu tím (Accent) khi chọn
        unselectedItemColor: Colors.grey,           // Màu xám khi không chọn
        showUnselectedLabels: true,
        
        selectedFontSize: 12,
        unselectedFontSize: 12,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_outlined),
            activeIcon: Icon(Icons.collections_bookmark),
            label: 'Thư viện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}