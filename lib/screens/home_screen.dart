import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/anime_controller.dart';
import '../models/anime_model.dart';
import 'detail_screen.dart';

// Halaman Home (25%) menggunakan GetX State Management (Obx & Controller)
// Sesuai Modul 8: StatelessWidget yang reaktif terhadap perubahan state Controller
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller GetX
    final AnimeController controller = Get.put(AnimeController());

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.play_circle_filled_rounded, color: Colors.deepOrange, size: 28),
            SizedBox(width: 8),
            Text(
              'Keripikroll',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      // Obx mendengarkan variabel reaktif (isLoading, animeList) di controller
      body: Obx(() {
        // c. Loading indicator saat memuat data anime
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange),
          );
        }

        // Tampilan error jika koneksi gagal
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.deepOrange, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat data anime:\n${controller.errorMessage.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.fetchAnime,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  ),
                ],
              ),
            ),
          );
        }

        // b. GridView responsif (2 kolom di HP/emulator, menyesuaikan bila di browser Web)
        return RefreshIndicator(
          color: Colors.deepOrange,
          onRefresh: controller.fetchAnime,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Menghitung jumlah kolom agar proporsional di mobile maupun web browser
              int crossAxisCount = 2;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 5;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.animeList.length,
                itemBuilder: (context, index) {
                  final anime = controller.animeList[index];
                  return _buildAnimeCard(context, anime);
                },
              );
            },
          ),
        );
      }),
    );
  }

  // Widget kartu anime dalam GridView
  Widget _buildAnimeCard(BuildContext context, AnimeModel anime) {
    return GestureDetector(
      onTap: () {
        // Navigasi GetX ke Detail Page
        Get.to(() => DetailScreen(animeId: anime.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // i. Poster Image
            Expanded(
              child: anime.safePosterImage.isNotEmpty
                  ? Image.network(
                      anime.safePosterImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFF252525),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.grey, size: 36),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ii. Nama Anime (titles -> en_jp)
                  Text(
                    anime.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // iii. Rating Umur (ageRating) & Episode
                  Text(
                    anime.episodeCount != null
                        ? '${anime.ageRating} • ${anime.episodeCount} Episodes'
                        : anime.ageRating,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // iv. Rating (averageRating)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        anime.averageRating,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
