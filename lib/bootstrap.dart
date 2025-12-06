// lib/bootstrap.dart

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'di/locator.dart';

// IMPORT CÁC MODULE MANIFEST
import 'package:auth/auth_module.dart';
import 'package:library_manga/library_module.dart';
import 'package:discovery/discovery_module.dart';
import 'package:catalog/catalog_module.dart';
import 'package:reader/reader_module.dart';
import 'package:home/home_module.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Local Storage
  await Hive.initFlutter();

  // 2. Init Service Locator
  setupLocator();
  final sl = GetIt.instance;

  // 3. Init Core Dependencies (Network / DB)
  // FIX LỖI MẠNG: Cấu hình Dio chuẩn cho MangaDex
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio(
          BaseOptions(
            baseUrl: 'https://api.mangadex.org',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              // User-Agent bắt buộc để không bị chặn
              'User-Agent': 'MangaReaderApp/0.0.1 (flutter)',
            },
            // Quan trọng: Tắt persistent connection để tránh lỗi "Connection closed before full header"
            persistentConnection: false, 
          ),
        ));
  }
  
  if (!sl.isRegistered<FirebaseFirestore>()) {
      sl.registerLazySingleton(() => FirebaseFirestore.instance);
  }

  // 4. INIT MODULES (Thứ tự quan trọng)
  try {
    await AuthModule.di();    // Auth trước
    await LibraryModule.di(); // Library cần Auth
    await DiscoveryModule.di();
    await CatalogModule.di();
    await ReaderModule.di();  // Reader cần Library & Catalog
    await HomeModule.di();    // Home cần Discovery & Library
  } catch (e) {
    debugPrint("❌ Lỗi khởi tạo Module: $e");
  }
  
  debugPrint("✅ BOOTSTRAP COMPLETE");
}