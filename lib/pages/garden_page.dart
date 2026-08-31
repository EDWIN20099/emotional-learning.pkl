import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // DATA BUNGA
  // ============================================================

  final List<Map<String, dynamic>> flowers = [
    {
      'id': 'sunflower',
      'name': 'Matahari',
      'emoji': '🌻',
      'softColor': const Color(0xFFFFF3C4),
    },
    {
      'id': 'tulip',
      'name': 'Tulip',
      'emoji': '🌷',
      'softColor': const Color(0xFFFFE4F0),
    },
    {
      'id': 'rose',
      'name': 'Mawar',
      'emoji': '🌹',
      'softColor': const Color(0xFFFFE0E0),
    },
    {
      'id': 'daisy',
      'name': 'Daisy',
      'emoji': '🌼',
      'softColor': const Color(0xFFFFF5CE),
    },
  ];

  final List<Map<String, dynamic>> plantedFlowers = [];

  int flowerCount = 0;
  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadGarden();
  }

  // ============================================================
  // LOAD REWARD
  // ============================================================

  Future<void> _loadGarden() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final response = await _supabase
          .from('user_rewards')
          .select('id, reward_type, created_at')
          .eq('user_id', user.id)
          .eq('reward_type', 'flower')
          .order('created_at', ascending: true);

      if (!mounted) return;

      final List<Map<String, dynamic>> loadedFlowers = [];

      for (int i = 0; i < response.length; i++) {
        final flower = flowers[i % flowers.length];

        loadedFlowers.add({
          'id': response[i]['id'].toString(),
          'flowerId': flower['id'],
          'name': flower['name'],
          'emoji': flower['emoji'],
          'x': _defaultX(i),
          'y': _defaultY(i),
        });
      }

      setState(() {
        flowerCount = response.length;
        plantedFlowers
          ..clear()
          ..addAll(loadedFlowers);

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // DEFAULT POSITION BUNGA
  // ============================================================

  double _defaultX(int index) {
    const positions = [0.18, 0.39, 0.60, 0.82, 0.28, 0.50, 0.72, 0.10];

    return positions[index % positions.length];
  }

  double _defaultY(int index) {
    const positions = [0.70, 0.56, 0.70, 0.57, 0.46, 0.76, 0.46, 0.58];

    return positions[index % positions.length];
  }

  // ============================================================
  // COUNT PER FLOWER
  // ============================================================

  int _getFlowerTypeCount(String flowerId) {
    return plantedFlowers
        .where((flower) => flower['flowerId'] == flowerId)
        .length;
  }

  // ============================================================
  // TANAM BUNGA
  // ============================================================

  void _plantFlower(String flowerId, {double? x, double? y}) {
    final flower = flowers.firstWhere((item) => item['id'] == flowerId);

    setState(() {
      plantedFlowers.add({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'flowerId': flower['id'],
        'name': flower['name'],
        'emoji': flower['emoji'],
        'x': (x ?? 0.50).clamp(0.08, 0.92),
        'y': (y ?? 0.70).clamp(0.50, 0.88),
      });
    });
  }

  // ============================================================
  // PINDAH BUNGA
  // ============================================================

  void _moveFlower(int index, double x, double y) {
    if (index < 0 || index >= plantedFlowers.length) return;

    setState(() {
      plantedFlowers[index]['x'] = x.clamp(0.06, 0.94);

      plantedFlowers[index]['y'] = y.clamp(0.48, 0.90);
    });
  }

  // ============================================================
  // BACK
  // ============================================================

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool landscape = constraints.maxWidth > constraints.maxHeight;

            return Column(
              children: [
                _buildHeader(landscape: landscape),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            landscape ? 24 : 14,
                            4,
                            landscape ? 24 : 14,
                            20,
                          ),
                          child: Column(
                            children: [
                              _buildGarden(landscape: landscape),

                              const SizedBox(height: 14),

                              _buildFlowerSelector(landscape: landscape),
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({required bool landscape}) {
    final double titleSize = landscape ? 27 : 25;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        landscape ? 24 : 14,
        landscape ? 6 : 8,
        landscape ? 24 : 14,
        5,
      ),
      child: Row(
        children: [
          // BACK
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: _goBack,
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: landscape ? 52 : 48,
                height: landscape ? 52 : 48,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF173C70),
                  size: 30,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // TITLE
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Taman Emosi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF173C70),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text('🌻', style: TextStyle(fontSize: landscape ? 27 : 25)),
              ],
            ),
          ),

          // JUMLAH BUNGA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8E7),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFB8DFAE), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌸', style: TextStyle(fontSize: 19)),
                const SizedBox(width: 4),
                Text(
                  '$flowerCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2B6838),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GARDEN
  // ============================================================

  Widget _buildGarden({required bool landscape}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebih tinggi di landscape supaya taman terasa luas.
        final double gardenHeight = landscape ? 345 : 405;

        return Container(
          height: gardenHeight,
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.09),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ==================================================
              // LANGIT
              // ==================================================

              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF70D7F5), Color(0xFFDFF7E8)],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // MATAHARI
              // ==================================================
              Positioned(
                top: 18,
                right: 28,
                child: Text(
                  '☀️',
                  style: TextStyle(fontSize: landscape ? 58 : 54),
                ),
              ),

              // ==================================================
              // AWAN
              // ==================================================
              const Positioned(
                left: 25,
                top: 22,
                child: Text('☁️', style: TextStyle(fontSize: 45)),
              ),

              const Positioned(
                left: 190,
                top: 42,
                child: Text('☁️', style: TextStyle(fontSize: 35)),
              ),

              // ==================================================
              // PELANGI
              // ==================================================
              Positioned(
                left: landscape ? 85 : 45,
                top: 62,
                child: Text(
                  '🌈',
                  style: TextStyle(fontSize: landscape ? 82 : 75),
                ),
              ),

              // ==================================================
              // KUPU-KUPU
              // ==================================================
              const Positioned(
                left: 330,
                top: 82,
                child: Text('🦋', style: TextStyle(fontSize: 25)),
              ),

              const Positioned(
                right: 125,
                top: 115,
                child: Text('🦋', style: TextStyle(fontSize: 22)),
              ),

              // ==================================================
              // BUKIT
              // ==================================================
              Positioned(
                left: -70,
                right: -70,
                top: 155,
                height: 105,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF9DD867),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // RUMPUT
              // ==================================================
              Positioned(
                left: 0,
                right: 0,
                top: 218,
                height: 53,
                child: Container(
                  color: const Color(0xFF4DB83F),
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      '🌿   🌱   🌿   🌱   🌿',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // TANAH
              // ==================================================
              Positioned(
                left: 0,
                right: 0,
                top: 266,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFAA6C3D), Color(0xFF8C542D)],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // BATU KIRI
              // ==================================================
              const Positioned(
                left: 28,
                bottom: 27,
                child: Text('🪨', style: TextStyle(fontSize: 32)),
              ),

              // ==================================================
              // BATU KANAN
              // ==================================================
              const Positioned(
                right: 25,
                bottom: 27,
                child: Text('🪨', style: TextStyle(fontSize: 32)),
              ),

              // ==================================================
              // PAPAN TAMAN
              // ==================================================
              Positioned(
                right: 22,
                top: 145,
                child: Transform.rotate(
                  angle: 0.02,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB97A42),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF8A542C),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'Tamanmu\nKeren! 💗',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // PESAN KECIL
              // ==================================================
              if (plantedFlowers.isEmpty)
                _buildSimpleGardenMessage(landscape: landscape),

              // ==================================================
              // BUNGA YANG SUDAH DITANAM
              // ==================================================
              ...plantedFlowers.asMap().entries.map((entry) {
                return _buildPlacedFlower(
                  index: entry.key,
                  flower: entry.value,
                  gardenWidth: constraints.maxWidth,
                  gardenHeight: gardenHeight,
                  landscape: landscape,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PESAN TAMAN KOSONG
  // ============================================================

  Widget _buildSimpleGardenMessage({required bool landscape}) {
    return Positioned(
      top: landscape ? 105 : 125,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD7EBD0), width: 1.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌱', style: TextStyle(fontSize: 20)),
              SizedBox(width: 6),
              Text(
                'Pilih bunga di bawah untuk menanam',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF315B42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUNGA DI TAMAN
  // ============================================================

  Widget _buildPlacedFlower({
    required int index,
    required Map<String, dynamic> flower,
    required double gardenWidth,
    required double gardenHeight,
    required bool landscape,
  }) {
    final double x = (flower['x'] as num).toDouble();

    final double y = (flower['y'] as num).toDouble();

    final double flowerSize = landscape ? 54 : 52;

    // Posisi berdasarkan ukuran TAMAN,
    // bukan ukuran layar HP.
    final double left = (x * gardenWidth) - (flowerSize / 2);

    final double top = (y * gardenHeight) - (flowerSize / 2);

    return Positioned(
      left: left.clamp(4.0, gardenWidth - flowerSize - 4),
      top: top.clamp(265.0, gardenHeight - flowerSize - 3),
      child: GestureDetector(
        onPanUpdate: (details) {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

          if (renderBox == null) return;

          final Offset local = renderBox.globalToLocal(details.globalPosition);

          final double newX = local.dx / gardenWidth;

          final double newY = local.dy / gardenHeight;

          _moveFlower(index, newX, newY);
        },
        child: SizedBox(
          width: flowerSize,
          height: flowerSize + 10,
          child: Text(
            flower['emoji'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: landscape ? 49 : 47),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PILIHAN BUNGA
  // ============================================================

  Widget _buildFlowerSelector({required bool landscape}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // HP portrait = 2 x 2
        if (!landscape && constraints.maxWidth < 650) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildFlowerCard(flowers[0])),
                  const SizedBox(width: 10),
                  Expanded(child: _buildFlowerCard(flowers[1])),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildFlowerCard(flowers[2])),
                  const SizedBox(width: 10),
                  Expanded(child: _buildFlowerCard(flowers[3])),
                ],
              ),
            ],
          );
        }

        // Landscape = 4 kartu sejajar
        return Row(
          children: flowers.map((flower) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildFlowerCard(flower),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============================================================
  // KARTU BUNGA
  // ============================================================

  Widget _buildFlowerCard(Map<String, dynamic> flower) {
    final String flowerId = flower['id'] as String;

    final String name = flower['name'] as String;

    final String emoji = flower['emoji'] as String;

    final int count = _getFlowerTypeCount(flowerId);

    return GestureDetector(
      onTap: () {
        _plantFlower(flowerId);
      },
      child: Container(
        height: 132,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE4E4E4), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ==================================================
            // JUMLAH
            // ==================================================

            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: count > 0
                      ? const Color(0xFFE8F8E4)
                      : const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: count > 0
                        ? const Color(0xFFB9DEB3)
                        : const Color(0xFFFFC8C8),
                  ),
                ),
                child: Text(
                  '×$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: count > 0
                        ? const Color(0xFF37713D)
                        : const Color(0xFFE45D5D),
                  ),
                ),
              ),
            ),

            // ==================================================
            // ISI KARTU
            // ==================================================
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 7,
                  left: 7,
                  right: 7,
                  bottom: 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // BUNGA
                    Draggable<Map<String, dynamic>>(
                      data: flower,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 54),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.25,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 43)),
                    ),

                    const SizedBox(height: 1),

                    // NAMA
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF173C70),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // TOMBOL TANAM
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F6C8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        '🌱 Tanam',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF397329),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
