import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../article/screens/article_list_screen.dart';
import '../../article/screens/my_articles_screen.dart';
import '../../billing/screens/billing_transactions_screen.dart';
import '../../billing/screens/premium_plans_screen.dart';
import '../../community/screens/community_stats_screen.dart';
import '../../forum/screens/forum_list_screen.dart';
import '../../gamification/screens/journey_summary_screen.dart';
import '../../gamification/screens/progress_map_screen.dart';
import '../../gamification/screens/rewards_screen.dart';
import '../../story/screens/story_list_screen.dart';
import '../../story/screens/my_stories_screen.dart';
import '../../journal/screens/public_journals_screen.dart';

class CommunityHubScreen extends StatelessWidget {
  final String tab;
  const CommunityHubScreen({super.key, this.tab = 'forum'});

  @override
  Widget build(BuildContext context) => _MemberTabHub(
    title: 'Komunitas',
    route: '/community',
    tab: tab,
    labels: const ['Forum', 'Kisah', 'Jurnal Publik', 'Statistik'],
    keys: const ['forum', 'stories', 'journals', 'stats'],
    children: const [
      ForumListScreen(showAppBar: false),
      _StoriesPanel(),
      PublicJournalsScreen(),
      CommunityStatsScreen(showAppBar: false),
    ],
  );
}

class _StoriesPanel extends StatelessWidget {
  const _StoriesPanel();

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Column(
      children: const [
        TabBar(
          isScrollable: false,
          tabs: [
            Tab(text: 'Jelajahi kisah'),
            Tab(text: 'Kisah saya'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [StoryListScreen(showAppBar: false), MyStoriesScreen()],
          ),
        ),
      ],
    ),
  );
}

class ArticleHubScreen extends StatelessWidget {
  final String tab;
  const ArticleHubScreen({super.key, this.tab = 'explore'});

  @override
  Widget build(BuildContext context) => _MemberTabHub(
    title: 'Artikel & Bacaan',
    route: '/articles',
    tab: tab,
    labels: const ['Jelajahi', 'Artikel Saya'],
    keys: const ['explore', 'mine'],
    children: const [ArticleListScreen(showAppBar: false), MyArticlesScreen()],
  );
}

class JourneyHubScreen extends StatelessWidget {
  final String tab;
  const JourneyHubScreen({super.key, this.tab = 'summary'});

  @override
  Widget build(BuildContext context) => _MemberTabHub(
    title: 'Perjalananmu',
    route: '/journey',
    tab: tab,
    labels: const ['Ringkasan', 'Peta', 'Hadiah'],
    keys: const ['summary', 'map', 'rewards'],
    children: const [
      JourneySummaryScreen(showAppBar: false),
      ProgressMapScreen(showAppBar: false),
      RewardsScreen(showAppBar: false),
    ],
  );
}

class BillingHubScreen extends StatelessWidget {
  final String tab;
  const BillingHubScreen({super.key, this.tab = 'packages'});

  @override
  Widget build(BuildContext context) => _MemberTabHub(
    title: 'Paket & Koin',
    route: '/billing',
    tab: tab,
    labels: const ['Paket', 'Koin', 'Transaksi'],
    keys: const ['packages', 'coins', 'transactions'],
    children: const [
      PremiumPlansScreen(mode: BillingCatalogMode.packages, showAppBar: false),
      PremiumPlansScreen(mode: BillingCatalogMode.coins, showAppBar: false),
      BillingTransactionsScreen(showAppBar: false),
    ],
  );
}

class _MemberTabHub extends StatefulWidget {
  final String title;
  final String route;
  final String tab;
  final List<String> labels;
  final List<String> keys;
  final List<Widget> children;
  const _MemberTabHub({
    required this.title,
    required this.route,
    required this.tab,
    required this.labels,
    required this.keys,
    required this.children,
  });

  @override
  State<_MemberTabHub> createState() => _MemberTabHubState();
}

class _MemberTabHubState extends State<_MemberTabHub>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? _pendingTab;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: widget.keys.length,
      vsync: this,
      initialIndex: _index(widget.tab),
    );
    _tabs.addListener(_syncRoute);
  }

  int _index(String tab) {
    final index = widget.keys.indexOf(tab);
    return index < 0 ? 0 : index;
  }

  void _syncRoute() {
    final tab = widget.keys[_tabs.index];
    if (tab == widget.tab || tab == _pendingTab) return;
    _pendingTab = tab;
    final uri = tab == widget.keys.first
        ? widget.route
        : '${widget.route}?tab=$tab';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingTab = null;
      if (mounted && tab != widget.tab) context.replace(uri);
    });
  }

  @override
  void didUpdateWidget(covariant _MemberTabHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = _index(widget.tab);
    if (index != _tabs.index) _tabs.animateTo(index);
  }

  @override
  void dispose() {
    _tabs.removeListener(_syncRoute);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: TabBar(
        controller: _tabs,
        isScrollable: false,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        dividerColor: AppColors.border,
        tabs: widget.labels
            .map(
              (label) => Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, maxLines: 1),
                ),
              ),
            )
            .toList(),
      ),
    ),
    body: TabBarView(controller: _tabs, children: widget.children),
  );
}
