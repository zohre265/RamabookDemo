import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final Map<String, AudioPlayer> _players = {};

  /// پخش صدا از assets/audio
  Future<void> play(String key, String fileName,
      {bool loop = false, double volume = 1.0}) async {
    // اگر پلیر وجود نداره، بساز
    if (!_players.containsKey(key)) {
      _players[key] = AudioPlayer();
    }

    final player = _players[key]!;
    await player.setSourceAsset("audio/$fileName");
    await player.setVolume(volume);
    await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    await player.resume();
  }

  /// توقف یک صدا
  Future<void> stop(String key) async {
    if (_players.containsKey(key)) {
      await _players[key]!.stop();
    }
  }

  /// توقف همه صداها
  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
  }

  /// تغییر ولوم یک صدا
  Future<void> setVolume(String key, double volume) async {
    if (_players.containsKey(key)) {
      await _players[key]!.setVolume(volume);
    }
  }
}
