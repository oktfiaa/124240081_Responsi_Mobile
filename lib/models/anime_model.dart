import 'package:flutter/foundation.dart';

// Helper untuk Flutter Web: browser memblokir request gambar lintas domain (CORS) dari Kitsu CDN.
// Pada Android / iOS (device/emulator), kIsWeb bernilai false sehingga URL asli digunakan langsung.
// Pada Web, diarahkan melalui image cache proxy agar lolos proteksi CORS browser.
String getSafeImageUrl(String url) {
  if (url.isEmpty) return '';
  if (kIsWeb) {
    return 'https://wsrv.nl/?url=${Uri.encodeComponent(url)}';
  }
  return url;
}

// Model data anime untuk menampung response dari API Kitsu dan data Hive
class AnimeModel {
  final String id;
  final String title;
  final String posterImage;
  final String coverImage;
  final String ageRating;
  final String averageRating;
  final int? episodeCount;
  final String synopsis;

  AnimeModel({
    required this.id,
    required this.title,
    required this.posterImage,
    required this.coverImage,
    required this.ageRating,
    required this.averageRating,
    this.episodeCount,
    required this.synopsis,
  });

  // Getter gambar yang aman untuk Mobile maupun Web
  String get safePosterImage => getSafeImageUrl(posterImage);
  String get safeCoverImage => getSafeImageUrl(coverImage);

  // Factory method untuk parse JSON dari Kitsu API
  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    final attributes = (json['attributes'] as Map<String, dynamic>?) ?? {};
    final titles = attributes['titles'] as Map<String, dynamic>?;
    final posterMap = attributes['posterImage'] as Map<String, dynamic>?;
    final coverMap = attributes['coverImage'] as Map<String, dynamic>?;

    // Clue key: titles -> en_jp (fallback ke en atau canonicalTitle jika kosong)
    final title = titles?['en_jp'] ??
        titles?['en'] ??
        attributes['canonicalTitle'] ??
        'Judul Tidak Tersedia';

    // Clue key: posterImage -> tiny/small/medium/original
    final poster = posterMap?['small'] ??
        posterMap?['medium'] ??
        posterMap?['original'] ??
        posterMap?['tiny'] ??
        '';

    // Clue key: coverImage -> tiny/small/large/original (fallback ke poster jika null)
    final cover = coverMap?['original'] ??
        coverMap?['large'] ??
        coverMap?['small'] ??
        coverMap?['tiny'] ??
        poster;

    return AnimeModel(
      id: json['id']?.toString() ?? '',
      title: title,
      posterImage: poster,
      coverImage: cover,
      ageRating: attributes['ageRating']?.toString() ?? 'PG',
      averageRating: attributes['averageRating']?.toString() ?? '0.0',
      episodeCount: attributes['episodeCount'] as int?,
      synopsis: attributes['synopsis']?.toString() ?? 'Tidak ada sinopsis.',
    );
  }

  // Konversi ke Map agar dapat disimpan ke database lokal Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterImage': posterImage,
      'coverImage': coverImage,
      'ageRating': ageRating,
      'averageRating': averageRating,
      'episodeCount': episodeCount,
      'synopsis': synopsis,
    };
  }

  // Factory method untuk membaca kembali data dari Hive (berupa Map)
  factory AnimeModel.fromMap(Map<dynamic, dynamic> map) {
    return AnimeModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Judul Tidak Tersedia',
      posterImage: map['posterImage']?.toString() ?? '',
      coverImage: map['coverImage']?.toString() ?? '',
      ageRating: map['ageRating']?.toString() ?? 'PG',
      averageRating: map['averageRating']?.toString() ?? '0.0',
      episodeCount: map['episodeCount'] as int?,
      synopsis: map['synopsis']?.toString() ?? 'Tidak ada sinopsis.',
    );
  }
}
