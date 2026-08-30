import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  final supabase = Supabase.instance.client;

  // =========================
  // DATA BUNGA
  // =========================

  final Map<String, Map<String, String>> flowerData = {
    'sunflower': {
      'emoji': '🌻',
      'name': 'Matahari',
      'rewardName': 'Bunga Matahari',
    },
    'tulip': {'emoji': '🌷', 'name': 'Tulip', 'rewardName': 'Bunga Tulip'},
    'rose': {'emoji': '🌹', 'name': 'Mawar', 'rewardName': 'Bunga Mawar'},
    'daisy': {'emoji': '🌼', 'name': 'Daisy', 'rewardName': 'Bunga Daisy'},
  };

  // =========================
  // BUNGA YANG SUDAH DITANAM
  // =========================

  List<Map<String, dynamic>> placedFlowers = [];

  // =========================
  // JUMLAH REWARD
  // =========================

  Map<String, int> rewardCounts = {
    'sunflower': 0,
    'tulip': 0,
    'rose': 0,
    'daisy': 0,
  };

  bool isLoading = true;

  int? draggingFlowerIndex;

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();
    loadGarden();
  }

  // =========================
  // LOAD GARDEN
  // =========================

  Future<void> loadGarden() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      // =========================
      // AMBIL REWARD USER
      // =========================

      final rewards = await supabase
          .from('user_rewards')
          .select()
          .eq('user_id', user.id)
          .eq('reward_type', 'flower');

      final newRewardCounts = {
        'sunflower': 0,
        'tulip': 0,
        'rose': 0,
        'daisy': 0,
      };

      for (final reward in rewards) {
        final rewardName = reward['reward_name']?.toString();

        if (rewardName == 'Bunga Matahari') {
          newRewardCounts['sunflower'] = newRewardCounts['sunflower']! + 1;
        } else if (rewardName == 'Bunga Tulip') {
          newRewardCounts['tulip'] = newRewardCounts['tulip']! + 1;
        } else if (rewardName == 'Bunga Mawar') {
          newRewardCounts['rose'] = newRewardCounts['rose']! + 1;
        } else if (rewardName == 'Bunga Daisy') {
          newRewardCounts['daisy'] = newRewardCounts['daisy']! + 1;
        }
      }

      // =========================
      // AMBIL BUNGA YANG SUDAH
      // DITANAM
      // =========================

      final gardenData = await supabase
          .from('garden_flowers')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      final loadedFlowers = List<Map<String, dynamic>>.from(gardenData);

      if (!mounted) return;

      setState(() {
        rewardCounts = newRewardCounts;
        placedFlowers = loadedFlowers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR LOAD GARDEN: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat Garden: $e')));
    }
  }

  // =========================
  // HITUNG STOK TERSEDIA
  // =========================

  int getAvailableStock(String flowerType) {
    final totalReward = rewardCounts[flowerType] ?? 0;

    final plantedCount = placedFlowers
        .where((flower) => flower['flower_type'] == flowerType)
        .length;

    final stock = totalReward - plantedCount;

    return stock < 0 ? 0 : stock;
  }

  // =========================
  // TAMBAH BUNGA
  // =========================

  Future<void> addFlower(
    String flowerType,
    double gardenWidth,
    double gardenHeight,
  ) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage('Kamu belum login.');
      return;
    }

    final stock = getAvailableStock(flowerType);

    if (stock <= 0) {
      showEmptyFlowerDialog(flowerData[flowerType]?['name'] ?? 'Bunga');
      return;
    }

    const flowerSize = 58.0;

    // =========================
    // POSISI AWAL DI TENGAH
    // =========================

    final xPosition = ((gardenWidth - flowerSize) / 2).clamp(0.0, gardenWidth);

    final yPosition = ((gardenHeight - flowerSize) / 2).clamp(
      0.0,
      gardenHeight,
    );

    try {
      final inserted = await supabase
          .from('garden_flowers')
          .insert({
            'user_id': user.id,
            'flower_type': flowerType,
            'x_position': xPosition,
            'y_position': yPosition,
          })
          .select()
          .single();

      if (!mounted) return;

      setState(() {
        placedFlowers.add(Map<String, dynamic>.from(inserted));
      });
    } catch (e) {
      debugPrint('ERROR ADD FLOWER: $e');

      showMessage('Gagal menanam bunga.');
    }
  }

  // =========================
  // UPDATE POSISI BUNGA
  // =========================

  Future<void> updateFlowerPosition(int index, double newX, double newY) async {
    if (index < 0 || index >= placedFlowers.length) {
      return;
    }

    final flower = placedFlowers[index];

    final flowerId = flower['id'];

    try {
      await supabase
          .from('garden_flowers')
          .update({'x_position': newX, 'y_position': newY})
          .eq('id', flowerId);
    } catch (e) {
      debugPrint('ERROR UPDATE FLOWER POSITION: $e');
    }
  }

  // =========================
  // DRAG BUNGA
  // =========================

  void updateFlowerDrag(
    int index,
    DragUpdateDetails details,
    double gardenWidth,
    double gardenHeight,
  ) {
    if (index < 0 || index >= placedFlowers.length) {
      return;
    }

    const flowerSize = 58.0;

    final flower = placedFlowers[index];

    final currentX = (flower['x_position'] as num?)?.toDouble() ?? 0.0;

    final currentY = (flower['y_position'] as num?)?.toDouble() ?? 0.0;

    double newX = currentX + details.delta.dx;

    double newY = currentY + details.delta.dy;

    final maxX = gardenWidth - flowerSize;

    final maxY = gardenHeight - flowerSize;

    newX = newX.clamp(0.0, maxX < 0 ? 0.0 : maxX);

    newY = newY.clamp(0.0, maxY < 0 ? 0.0 : maxY);

    setState(() {
      placedFlowers[index]['x_position'] = newX;

      placedFlowers[index]['y_position'] = newY;
    });

    // Simpan ke database
    updateFlowerPosition(index, newX, newY);
  }

  // =========================
  // POPUP BUNGA HABIS
  // =========================

  void showEmptyFlowerDialog(String flowerName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '🌱 Bunga Sudah Habis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B3B6F),
            ),
          ),
          content: Text(
            'Bunga $flowerName kamu sudah habis.\n\n'
            'Selesaikan cerita dan quiz untuk mendapatkan bunga lagi! 🌸',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF66809F),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC928),
                  foregroundColor: const Color(0xFF1B3B6F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Oke, Siap! ✨',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // MESSAGE
  // =========================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // =========================
  // TOMBOL BUNGA
  // =========================

  Widget flowerButton({
    required String flowerType,
    required double width,
    required double height,
    required bool compact,
  }) {
    final data = flowerData[flowerType]!;

    final stock = getAvailableStock(flowerType);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          addFlower(flowerType, width, height);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCE8F5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['emoji']!,
                style: TextStyle(fontSize: compact ? 25 : 32),
              ),

              SizedBox(height: compact ? 2 : 4),

              Text(
                data['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B3B6F),
                ),
              ),

              SizedBox(height: compact ? 3 : 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stock == 0 ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '×$stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: stock == 0 ? Colors.red : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFDF5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, pageConstraints) {
            final compact =
                pageConstraints.maxWidth < 600 ||
                pageConstraints.maxHeight < 500;

            return Column(
              children: [
                // =========================
                // HEADER
                // =========================
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 20,
                    compact ? 8 : 16,
                    compact ? 12 : 20,
                    compact ? 8 : 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: compact ? 42 : 52,
                        height: compact ? 42 : 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFDCE8F5),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF1B3B6F),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Taman Emosi 🌻',
                          style: TextStyle(
                            fontSize: compact ? 20 : 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B3B6F),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 10 : 14,
                          vertical: compact ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🌱', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'Garden',
                              style: TextStyle(
                                fontSize: compact ? 12 : null,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2D6A4F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // AREA GARDEN
                // =========================
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFB3E5FC), // Langit cerah
                          Color(0xFFC8E6C9), // Hijau rumput lembut
                          Color(0xFFA5D6A7), // Hijau subur
                        ],
                        stops: [0.0, 0.35, 1.0],
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // =========================
                            // LANGIT (Matahari & Awan Lucu)
                            // =========================
                            const Positioned(
                              top: 20,
                              right: 24,
                              child: Text('☀️', style: TextStyle(fontSize: 44)),
                            ),

                            const Positioned(
                              top: 35,
                              left: 25,
                              child: Text('☁️', style: TextStyle(fontSize: 40)),
                            ),

                            const Positioned(
                              top: 90,
                              right: 90,
                              child: Text('☁️', style: TextStyle(fontSize: 30)),
                            ),

                            // =========================
                            // TANAH
                            // =========================
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 95,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFD7CCC8,
                                  ), // Coklat tanah lembut
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0xFFBCAAA4),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // =========================
                            // RUMPUT
                            // =========================
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 82,
                              child: Container(
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF72B95D),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                              ),
                            ),

                            const Positioned(
                              left: 20,
                              bottom: 82,
                              child: Text(
                                '🌿  🌱  🌿  🌱  🌿  🌱  🌿',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),

                            const Positioned(
                              right: 18,
                              bottom: 82,
                              child: Text(
                                '🌱  🌿  🌱  🌿',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),

                            const Positioned(
                              left: 115,
                              bottom: 105,
                              child: Text(
                                '🌾  🌾  🌾',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),

                            // =========================
                            // BATU
                            // =========================
                            const Positioned(
                              left: 35,
                              bottom: 30,
                              child: Text('🪨', style: TextStyle(fontSize: 32)),
                            ),

                            const Positioned(
                              right: 35,
                              bottom: 45,
                              child: Text('🪨', style: TextStyle(fontSize: 26)),
                            ),

                            // =========================
                            // BUNGA
                            // =========================
                            ...placedFlowers.asMap().entries.map((entry) {
                              final index = entry.key;

                              final flower = entry.value;

                              final flowerType = flower['flower_type']
                                  ?.toString();

                              final data = flowerData[flowerType];

                              if (data == null) {
                                return const SizedBox();
                              }

                              final x =
                                  (flower['x_position'] as num?)?.toDouble() ??
                                  0.0;

                              final y =
                                  (flower['y_position'] as num?)?.toDouble() ??
                                  0.0;

                              final isDragging = draggingFlowerIndex == index;

                              return Positioned(
                                left: x,
                                top: y,
                                child: GestureDetector(
                                  onPanStart: (details) {
                                    setState(() {
                                      draggingFlowerIndex = index;
                                    });
                                  },
                                  onPanUpdate: (details) {
                                    updateFlowerDrag(
                                      index,
                                      details,
                                      constraints.maxWidth,
                                      constraints.maxHeight,
                                    );
                                  },
                                  onPanEnd: (details) {
                                    setState(() {
                                      draggingFlowerIndex = null;
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale: isDragging ? 1.12 : 1.0,
                                    duration: const Duration(milliseconds: 100),
                                    child: Text(
                                      data['emoji']!,
                                      style: const TextStyle(fontSize: 58),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // =========================
                            // GARDEN KOSONG
                            // =========================
                            if (placedFlowers.isEmpty)
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🪴',
                                      style: TextStyle(fontSize: 60),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tamannya masih kosong nih!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1B3B6F),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Yuk pilih bunga di bawah\n'
                                      'untuk menghias taman indahmu! ✨',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF4A6572),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // =========================
                // TOMBOL BUNGA
                // =========================
                SizedBox(
                  height: compact ? 98 : 150,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 8 : 16,
                      compact ? 5 : 8,
                      compact ? 8 : 16,
                      compact ? 6 : 10,
                    ),
                    child: Row(
                      children: [
                        flowerButton(
                          flowerType: 'sunflower',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          compact: compact,
                        ),

                        flowerButton(
                          flowerType: 'tulip',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          compact: compact,
                        ),

                        flowerButton(
                          flowerType: 'rose',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          compact: compact,
                        ),

                        flowerButton(
                          flowerType: 'daisy',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          compact: compact,
                        ),
                      ],
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
