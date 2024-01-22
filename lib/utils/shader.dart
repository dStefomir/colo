import 'dart:ui';

/// Loads an shader
Future<FragmentShader> loadShader({required String asset}) async {
  try {
    final program = await FragmentProgram.fromAsset(asset);
    return program.fragmentShader();
  } catch (e) {
    rethrow;
  }
}