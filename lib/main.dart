import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/hive_adapters.dart';
import 'services/storage_service.dart';
import 'services/reddit_service.dart';
import 'services/content_aggregator_service.dart';
import 'providers/interests_provider.dart';
import 'providers/feed_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(ContentSourceAdapter());
  Hive.registerAdapter(FeedItemAdapter());
  Hive.registerAdapter(ScreenTimeEntryAdapter());

  final storageService = StorageService();
  await storageService.init();

  final reddit = RedditService();
  final aggregator = ContentAggregatorService(reddit: reddit);

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        contentAggregatorProvider.overrideWithValue(aggregator),
      ],
      child: const FirePlaceApp(),
    ),
  );
}
