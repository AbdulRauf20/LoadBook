import 'database.dart';

class LocalDatabaseService {
  LocalDatabaseService._();

  static final LocalDatabaseService instance = LocalDatabaseService._();

  final LoadBookDatabase database = LoadBookDatabase();
}
  