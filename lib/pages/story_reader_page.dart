import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'quiz_page.dart';
import '../utils/responsive.dart';

class StoryReaderPage extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryReaderPage({super.key, required this.story});

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> slides = [];
  int currentPage = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSlides();
  }

  // ============================================================
  // LOAD SLIDES DARI SUPABASE
  // ============================================================

  Future<void> loadSlides() async {
    try {
      final storyId = widget.story['id']?.toString();

      debugPrint('STORY DATA: ${widget.story}');
      debugPrint('STORY ID: $storyId');

      if (storyId == null || storyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          errorMessage = 'ID cerita tidak ditemukan.';
          isLoading = false;
        });

        return;
      }

      final data = await supabase
          .from('story_slides')
          .select()
          .eq('story_id', storyId)
          .order('slide_number', ascending: true);

      debugPrint('JUMLAH SLIDE: ${data.length}');

      if (!mounted) return;

      setState(() {
        slides = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR LOAD SLIDES: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ============================================================
  // SLIDE SEBELUMNYA
  // ============================================================

  void _prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  // ============================================================
  // SLIDE BERIKUTNYA
  // ============================================================

  void _nextPage() {
    if (currentPage < slides.length - 1) {
      setState(() {
        currentPage++;
      });
    } else {
      goToQuiz();
    }
  }

  // ============================================================
  // MASUK KE QUIZ
  // ============================================================

  Future<void> goToQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizPage(story: widget.story)),
    );

    if (!mounted) return;

    Navigator.pop(context, result);
  }

  // ============================================================
  // KONFIRMASI KELUAR
  // ============================================================

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Keluar dari cerita?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B3B6F),
            ),
          ),
          content: const Text(
            'Progress membaca cerita ini akan berhenti di halaman sekarang.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF71829F),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF71829F),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD15C),
                foregroundColor: const Color(0xFF1B3B6F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _fallbackSlideBackground(String emotionName) {
    final details = switch (emotionName.toLowerCase()) {
      'senang' => (const Color(0xFF8EDDD2), const Color(0xFFFFC928), '😊'),
      'sedih' => (const Color(0xFF8CC9F2), const Color(0xFF4D8DCC), '😢'),
      'marah' => (const Color(0xFFFFA69E), const Color(0xFFE45B51), '😡'),
      'jijik' => (const Color(0xFFA9D99A), const Color(0xFF5EAF68), '🤢'),
      _ => (const Color(0xFF9DDDD5), const Color(0xFF4C899A), '📖'),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [details.$1, details.$2],
        ),
      ),
      child: Center(
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.26),
          ),
          alignment: Alignment.center,
          child: Text(details.$3, style: const TextStyle(fontSize: 150)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emotion = widget.story['emotions'];

    final emotionName = emotion is Map
        ? emotion['name']?.toString() ?? 'Emosi'
        : 'Emosi';

    // ============================================================
    // LOADING
    // ============================================================

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B3B6F),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD15C)),
        ),
      );
    }

    // ============================================================
    // ERROR
    // ============================================================

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1B3B6F),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 60,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Terjadi Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ============================================================
    // TIDAK ADA SLIDE
    // ============================================================

    if (slides.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1B3B6F),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📚', style: TextStyle(fontSize: 60)),

                const SizedBox(height: 15),

                const Text(
                  'Cerita belum memiliki slide.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ============================================================
    // DATA SLIDE
    // ============================================================

    final slide = slides[currentPage];

    final slideTitle = slide['title']?.toString() ?? '';

    final content = slide['content']?.toString() ?? '';

    final rawImageUrl = slide['image_url']?.toString().trim() ?? '';
    final imageUrl = rawImageUrl.toLowerCase() == 'null' ? '' : rawImageUrl;

    final isLastPage = currentPage == slides.length - 1;

    // ============================================================
    // HALAMAN CERITA FULL SCREEN
    // ============================================================

    return Scaffold(
      backgroundColor: Colors.black,

      body: SizedBox.expand(
        child: Builder(
          builder: (context) {
            final r = Responsive(context);

            return Stack(
          fit: StackFit.expand,
          children: [
            // ========================================================
            // 1. GAMBAR FULL SCREEN
            // ========================================================
            Positioned.fill(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,

                      errorBuilder: (context, error, stackTrace) {
                        return _fallbackSlideBackground(emotionName);
                      },

                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            _fallbackSlideBackground(emotionName),
                            const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD15C),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : _fallbackSlideBackground(emotionName),
            ),

            // ========================================================
            // 2. OVERLAY GELAP
            // ========================================================
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.80),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // ========================================================
            // 3. HEADER
            // ========================================================
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // TOMBOL KELUAR
                    // ------------------------------------------------
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.55),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _showExitDialog,
                      icon: const Icon(Icons.close_rounded, size: 19),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // PROGRESS SLIDE
                    // ------------------------------------------------
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        '${currentPage + 1}/${slides.length} ✨',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ========================================================
            // 4. SUBTITLE / TEKS CERITA
            // ========================================================
            Positioned(
              left: r.w(90),
              right: r.w(90),
              bottom: 18,
              child: Column(
                children: [
                  // --------------------------------------------------
                  // JUDUL SLIDE
                  // --------------------------------------------------
                  if (slideTitle.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        slideTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --------------------------------------------------
                  // BOX SUBTITLE
                  // --------------------------------------------------
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        content,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --------------------------------------------------
                  // PETUNJUK
                  // --------------------------------------------------
                  const Text(
                    '✨ Baca ceritanya dan rasakan setiap momennya!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFD15C),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // 5. TOMBOL PREVIOUS
            // ========================================================
            Positioned(
              left: r.w(20),
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: currentPage > 0 ? _prevPage : null,
                    borderRadius: BorderRadius.circular(50),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: currentPage > 0 ? 1.0 : 0.35,
                      child: Container(
                        width: r.w(56),
                        height: r.w(56),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.60),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ========================================================
            // 6. TOMBOL NEXT
            // ========================================================
            Positioned(
              right: r.w(20),
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _nextPage,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: r.w(56),
                      height: r.w(56),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFD15C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFFD15C,
                            ).withValues(alpha: 0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.black87,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
          },
        ),
      ),
    );
  }
}