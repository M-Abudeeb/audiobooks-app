import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/audiobook_provider.dart';
import '../widgets/audiobook_card.dart';
import '../widgets/mini_player.dart';
import '../screens/player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            // Main content
            SafeArea(child: _buildCurrentPage()),

            // Mini player positioned above navigation
            const Positioned(
              left: 16,
              right: 16,
              bottom: 5, // Closer to the navigation bar
              height: 70,
              child: Material(color: Colors.transparent, child: MiniPlayer()),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildCategoriesPage();
      case 2:
        return _buildLibraryPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Consumer<AudioBookProvider>(
      builder: (context, provider, child) {
        final filteredBooks = _filterBooks(provider.audioBooks);

        if (provider.audioBooks.isEmpty) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          slivers: [
            // Custom App Bar
            _buildSliverAppBar(),

            // Search Bar
            SliverToBoxAdapter(child: _buildSearchBar()),

            // Featured Section
            SliverToBoxAdapter(child: _buildFeaturedSection(filteredBooks)),

            // Recently Added Section
            SliverToBoxAdapter(
              child: _buildRecentlyAddedSection(filteredBooks),
            ),

            // Categories Quick Access
            SliverToBoxAdapter(child: _buildCategoriesSection()),

            // Popular Books Grid
            SliverToBoxAdapter(child: _buildPopularBooksGrid(filteredBooks)),
          ],
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: false,
      snap: false,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0),
      // This creates a transparent effect that becomes more opaque when collapsed
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate opacity based on scroll position
          final double top = constraints.biggest.height;
          final double opacity =
              (140.0 - top + kToolbarHeight) / (140.0 - kToolbarHeight);
          final double clampedOpacity = opacity.clamp(0.0, 1.0);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(clampedOpacity),
                  Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(clampedOpacity * 0.8),
                ],
              ),
              // Add a subtle border when collapsed
              border:
                  clampedOpacity > 0.8
                      ? Border(
                        bottom: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      )
                      : null,
            ),
            child: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 24,
                right: 72,
                bottom: 16,
              ),
              title: null, // No title when collapsed
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'مرحباً فاضل 👋',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'استمتع بمكتبتك الصوتية',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: TextField(
        textDirection: TextDirection.rtl,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'ابحث عن كتاب صوتي...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              // Filter functionality
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(List<dynamic> books) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'أضيف مؤخراً',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18, // تصغير حجم الخط قليلاً
                  ),
                  maxLines: 2, // السماح بسطرين
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length.clamp(0, 3),
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildFeaturedBookCard(book),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBookCard(dynamic book) {
    return Consumer<AudioBookProvider>(
      builder: (context, provider, child) {
        final progress = provider.getSavedProgress(book.id);
        final progressPercentage =
            book.duration.inSeconds > 0
                ? progress.inSeconds / book.duration.inSeconds
                : 0.0;

        return GestureDetector(
          onTap: () => _playBook(book),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      book.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.book,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Book Title
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    book.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'دينية', 'icon': Icons.menu_book, 'count': 6},
      {'name': 'تاريخية', 'icon': Icons.history_edu, 'count': 0},
      {'name': 'أدبية', 'icon': Icons.auto_stories, 'count': 0},
      {'name': 'علمية', 'icon': Icons.science, 'count': 0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Text(
            'التصنيفات',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 1),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(left: 14),
                child: _buildCategoryCard(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category page
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category['icon'] as IconData,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'] as String,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text(
              '${category['count']} كتاب',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyAddedSection(List<dynamic> books) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'اكمل الاستماع',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        // Build list with separators like Apple Podcast
        ...books.take(3).map((book) {
          final booksList = books.take(3).toList();
          final index = booksList.indexOf(book);
          final isLast = index == booksList.length - 1;

          return Column(
            children: [
              _buildBookListTile(book),
              // Add separator line except for the last item
              if (!isLast)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 4,
                  ),
                  height: 1,
                  color: const Color(
                    0xFFE0E0E0,
                  ), // Light gray color - more visible
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBookListTile(dynamic book) {
    return Consumer<AudioBookProvider>(
      builder: (context, provider, child) {
        final progress = provider.getSavedProgress(book.id);
        final progressPercentage =
            book.duration.inSeconds > 0
                ? progress.inSeconds / book.duration.inSeconds
                : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: ListTile(
            onTap: () => _playBook(book),
            contentPadding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.transparent,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 64,
                child: Image.asset(
                  book.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.book,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              book.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(book.author, style: Theme.of(context).textTheme.bodySmall),
                if (progressPercentage > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Icon(
              Icons.play_circle_outline,
              color: Theme.of(context).colorScheme.onSurface,
              size: 32,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularBooksGrid(List<dynamic> books) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'الأكثر شعبية',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Better ratio to prevent overflow
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return AudioBookCard(
                book: book,
                progress: Provider.of<AudioBookProvider>(
                  context,
                  listen: false,
                ).getSavedProgress(book.id),
                onTap: () => _playBook(book),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.headphones_outlined,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'لا توجد كتب صوتية',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'أضف ملفاتك الصوتية لتبدأ الاستماع',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage() {
    return const Center(child: Text('صفحة التصنيفات قيد التطوير'));
  }

  Widget _buildLibraryPage() {
    return const Center(child: Text('صفحة المكتبة قيد التطوير'));
  }

  Widget _buildProfilePage() {
    return const Center(child: Text('صفحة الملف الشخصي قيد التطوير'));
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(
              0.4,
            ), // Semi-transparent at bottom
            Theme.of(
              context,
            ).colorScheme.surface.withOpacity(0.3), // Less opaque
            Theme.of(
              context,
            ).colorScheme.surface.withOpacity(0.2), // More transparent
            Theme.of(
              context,
            ).colorScheme.surface.withOpacity(0.1), // Very transparent
            Theme.of(
              context,
            ).colorScheme.surface.withOpacity(0.05), // Almost gone
            Colors.transparent, // Fully transparent at top
          ],
          stops: const [0.0, 0.30, 0.4, 0.6, 0.8, 1.0],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category),
                  label: 'التصنيفات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_books_outlined),
                  activeIcon: Icon(Icons.library_books),
                  label: 'مكتبتي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'الملف الشخصي',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<dynamic> _filterBooks(List<dynamic> books) {
    if (_searchQuery.isEmpty) return books;

    return books.where((book) {
      return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToPlayer(dynamic book) async {
    final provider = Provider.of<AudioBookProvider>(context, listen: false);
    await provider.playBookImmediately(book);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlayerScreen(book: book)),
      );
    }
  }

  void _playBook(dynamic book) async {
    final provider = Provider.of<AudioBookProvider>(context, listen: false);
    await provider.playBookImmediately(book);
  }
}
