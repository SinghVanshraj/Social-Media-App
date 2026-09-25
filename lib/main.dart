import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/widgets/error_offline_widgets.dart';
import 'package:social_media_app/feature/auth/auth_view.dart';
import 'package:social_media_app/feature/comments/comments_view.dart';
import 'package:social_media_app/feature/create_post/create_post_view.dart';
import 'package:social_media_app/feature/home_feed/home_feed_view.dart';
import 'package:social_media_app/feature/interest_selection/interest_selection_view.dart';
import 'package:social_media_app/feature/notifications/notifications_view.dart';
import 'package:social_media_app/feature/notifications/notifications_view_model.dart';
import 'package:social_media_app/helpers/profile/profile_setup_view.dart';
import 'package:social_media_app/feature/profile/profile_view.dart';
import 'package:social_media_app/feature/search/search_view.dart';
import 'package:social_media_app/helpers/profile/edit_profile_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'SUPABASE_URL',
    publishableKey: 'PUBLISHABLE_KEY',
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spark',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) =>
                  OfflineBanner(child: child ?? const SizedBox.shrink()),
            ),
          ],
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, 
        primaryColor: Colors.blueAccent[400],

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xFF16181C),
          thickness: 1,
        ),
      ),

      initialRoute: '/login',

      onGenerateRoute: (settings) {
        if (settings.name == '/comments') {
          return MaterialPageRoute(
            builder: (context) => const CommentsView(postId: 'default_id'),
          );
        }
        return null;
      },

      routes: {
        '/login': (context) => const LoginView(),
        '/signup': (context) => const SignUpView(),
        '/setup-profile': (context) => const ProfileSetupView(),
        '/': (context) => const MainNavigationShell(),
        '/create-post': (context) => const CreatePostView(),
        '/interests': (context) => const InterestSelectionView(),
        '/edit-profile': (context) => const EditProfileHelper(),
        '/search': (context) => const SearchView(),
      },
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeFeedView(),
    const SearchView(),
    NotificationsView(),
    ProfileView(userId: null),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(notificationsViewModelProvider).unreadCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 720;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  backgroundColor: Colors.black,
                  labelType: NavigationRailLabelType.none,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Spark',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.home_outlined, size: 26),
                      selectedIcon: Icon(
                        Icons.home_filled,
                        size: 26,
                        color: Colors.white,
                      ),
                      label: Text('Home'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.search_rounded, size: 26),
                      selectedIcon: Icon(
                        Icons.search_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                      label: Text('Search'),
                    ),
                    NavigationRailDestination(
                      icon: _buildBadgeIcon(
                        Icons.notifications_outlined,
                        unreadCount,
                        Colors.grey[400]!,
                      ),
                      selectedIcon: _buildBadgeIcon(
                        Icons.notifications_rounded,
                        unreadCount,
                        Colors.white,
                      ),
                      label: const Text('Alerts'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded, size: 26),
                      selectedIcon: Icon(
                        Icons.person_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFF16181C),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border:
                  Border(top: BorderSide(color: Color(0xFF16181C), width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey[600],
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 26),
                  activeIcon: Icon(
                    Icons.home_filled,
                    size: 26,
                    color: Colors.white,
                  ),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded, size: 26),
                  activeIcon: Icon(
                    Icons.search_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: _buildBadgeIcon(
                    Icons.notifications_outlined,
                    unreadCount,
                    Colors.grey[600]!,
                  ),
                  activeIcon: _buildBadgeIcon(
                    Icons.notifications_rounded,
                    unreadCount,
                    Colors.white,
                  ),
                  label: 'Alerts',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded, size: 26),
                  activeIcon: Icon(
                    Icons.person_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeIcon(IconData icon, int count, Color color) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 26, color: color),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
