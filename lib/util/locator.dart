import 'package:get_it/get_it.dart';
import 'package:survey_app/util/services/shared_preferences_service.dart';
import 'package:survey_app/util/utils.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<Utils>(Utils());
  getIt.registerLazySingleton<SharedPreferencesService>(() => SharedPreferencesService());
}
