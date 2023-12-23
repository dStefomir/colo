import 'package:flame_audio/flame_audio.dart';

/// Plays an looped audio asset
void playLooped({required String asset, double volume = 1}) {
  FlameAudio.loopLongAudio(asset, volume: volume);
}

/// Plays an audio asset
void play({required String asset, double volume = 1}) {
  FlameAudio.play(asset, volume: volume);
}