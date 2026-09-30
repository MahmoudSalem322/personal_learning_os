import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/local_backup_store.dart';
import '../domain/backup_service.dart';
import '../domain/backup_store.dart';

final backupStoreProvider = Provider<BackupStore>(
  (ref) => LocalBackupStore(ref.watch(appDatabaseProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(backupStoreProvider)),
);
