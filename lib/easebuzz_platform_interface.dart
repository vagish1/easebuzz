import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'easebuzz_method_channel.dart';

abstract class EasebuzzPlatform extends PlatformInterface {
  /// Constructs a EasebuzzPlatform.
  EasebuzzPlatform() : super(token: _token);

  static final Object _token = Object();

  static EasebuzzPlatform _instance = MethodChannelEasebuzz();

  /// The default instance of [EasebuzzPlatform] to use.
  ///
  /// Defaults to [MethodChannelEasebuzz].
  static EasebuzzPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EasebuzzPlatform] when
  /// they register themselves.
  static set instance(EasebuzzPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map<String, dynamic>> openGateway(
      {required String accessToken, required isProduction}) {
    throw UnimplementedError("openGateway() has not been implemented");
  }
}
