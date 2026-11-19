import 'package:get/get.dart';
import 'package:responsi_mobile/models/anime_model.dart';
import 'package:responsi_mobile/services/api_service.dart';

class AnimeController extends GetxController {
  final RxList<AnimeModel> animeList = <AnimeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnime(); 
  }

  Future<void> fetchAnime() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await ApiService.fetchAnimeList();
      animeList.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
