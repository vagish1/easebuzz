import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'easebuzz_platform_interface.dart';

/// An implementation of [EasebuzzPlatform] that uses method channels.
class MethodChannelEasebuzz extends EasebuzzPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('easebuzz');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<String, dynamic>> openGateway(
      {required String accessToken, required isProduction}) async {
    final Map<String, dynamic>? afterPayment = await methodChannel
        .invokeMethod<Map<String, dynamic>>('openPaymentGateway', {
      "access_key": accessToken,
      "pay_mode": isProduction ? "production" : "test"
    });
    return Future.value(afterPayment);
  }
}
