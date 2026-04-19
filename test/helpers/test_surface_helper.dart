import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets a large test surface size to prevent RenderFlex overflow errors
/// in tests. Call in setUp() before pumping widgets.
void setLargeTestSurface([Size size = const Size(1200, 2400)]) {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.views.first.physicalSize = size;
  binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  addTearDown(() {
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });
}
