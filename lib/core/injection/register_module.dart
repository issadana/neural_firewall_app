import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sentri/core/constants/api_constants.dart';
import 'package:Sentri/core/constants/app_constants.dart';
import 'package:Sentri/core/websocket/firewall_log_ws_service.dart';
import 'package:Sentri/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:Sentri/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:Sentri/features/traffic/data/datasources/ml_datasource.dart';
import 'package:Sentri/features/traffic/data/repositories/traffic_repository_impl.dart';
import 'package:Sentri/features/traffic/domain/repositories/traffic_repository.dart';
import 'package:Sentri/features/vpn/data/datasources/vpn_native_datasource.dart';

/// Registers third-party objects and the handful of app classes that can't be
/// constructor-injected directly (async init, primitive constructor params, or
/// two instances of the same type).
@module
abstract class RegisterModule {
  /// Shared API client — reused across every authenticated feature so a
  /// refreshed token propagates everywhere at once. [DioConsumer] reconfigures
  /// this client's options/interceptors on construction.
  @Named('apiDio')
  @lazySingleton
  Dio get apiDio => Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          sendTimeout: AppConstants.sendTimeout,
        ),
      );

  /// Dedicated client for the Nova chatbot's SSE stream, kept separate from the
  /// shared client so its streaming setup doesn't leak into other features.
  @Named('chatDio')
  @lazySingleton
  Dio get chatDio => Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          sendTimeout: AppConstants.sendTimeout,
        ),
      );

  /// Encrypted session store, shared by the auth repository and the refresh
  /// interceptor so they read/write the same tokens.
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  @preResolve
  Future<SharedPreferences> sharedPreferences() =>
      SharedPreferences.getInstance();

  /// The ML models need an async load before first inference; resolve it up
  /// front so the traffic pipeline is ready the moment listening starts.
  @preResolve
  Future<MlDataSource> mlDataSource() async {
    final ds = MlDataSource();
    await ds.init();
    return ds;
  }

  /// Real-time write path streaming processed firewall logs to the backend.
  /// Reads the current access token from secure storage on each (re)connect,
  /// so a refreshed token is picked up automatically.
  @lazySingleton
  FirewallLogWsService firewallLogWs(AuthLocalDataSource auth) =>
      FirewallLogWsService(
        baseHttpUrl: ApiConstants.baseUrl,
        tokenProvider: auth.getAccessToken,
      );

  /// Built here rather than by constructor injection because its threshold /
  /// scan primitives aren't DI-resolvable — they're seeded at runtime from the
  /// user's settings by [AppBootstrap]. Singleton so those setter mutations are
  /// shared across every consumer.
  @lazySingleton
  TrafficRepository trafficRepository(
    BlacklistRepository blacklistRepository,
    MlDataSource mlDataSource,
    VpnNativeDataSource vpnDataSource,
  ) =>
      TrafficRepositoryImpl(
        blacklistRepository: blacklistRepository,
        mlDataSource: mlDataSource,
        vpnDataSource: vpnDataSource,
      );
}
