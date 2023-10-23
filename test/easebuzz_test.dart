import 'package:easebuzz/easebuzz.dart';
import 'package:easebuzz/easebuzz_method_channel.dart';
import 'package:easebuzz/easebuzz_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEasebuzzPlatform
    with MockPlatformInterfaceMixin
    implements EasebuzzPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>> openGateway(
      {required String accessToken, required isProduction}) {
    throw UnimplementedError();
  }
}

void main() {
  final EasebuzzPlatform initialPlatform = EasebuzzPlatform.instance;

  test('$MethodChannelEasebuzz is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEasebuzz>());
  });

  test('getPlatformVersion', () async {
    Easebuzz easebuzzPlugin = Easebuzz();
    MockEasebuzzPlatform fakePlatform = MockEasebuzzPlatform();
    EasebuzzPlatform.instance = fakePlatform;

    expect(await easebuzzPlugin.getPlatformVersion(), '42');
  });
}
