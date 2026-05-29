import 'package:audioplayers/audioplayers.dart';

import 'progress_service.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = <AudioPlayer>[
    AudioPlayer(playerId: 'sfx-0'),
    AudioPlayer(playerId: 'sfx-1'),
    AudioPlayer(playerId: 'sfx-2'),
  ];

  ProgressService? _progressService;
  int _sfxIndex = 0;

  bool get soundEnabled => _progressService?.soundEnabled ?? true;
  bool get musicEnabled => _progressService?.musicEnabled ?? true;
  bool get vibrationEnabled => _progressService?.vibrationEnabled ?? true;

  Future<void> init(ProgressService progressService) async {
    _progressService = progressService;
    _progressService?.addListener(_syncToSettings);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    for (final AudioPlayer player in _sfxPlayers) {
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
    }
    await _syncToSettings();
  }

  Future<void> dispose() async {
    _progressService?.removeListener(_syncToSettings);
    await _musicPlayer.dispose();
    for (final AudioPlayer player in _sfxPlayers) {
      await player.dispose();
    }
  }

  Future<void> _syncToSettings() async {
    if (musicEnabled) {
      await _startMusic();
    } else {
      await _musicPlayer.stop();
    }
  }

  Future<void> _startMusic() async {
    if (_musicPlayer.state == PlayerState.playing) {
      return;
    }
    await _musicPlayer.stop();
    await _musicPlayer.play(
      AssetSource('audio/bgm_loop.wav'),
      volume: 0.30,
    );
  }

  Future<void> playButtonTap() async {
    await playEffect('audio/button_tap.wav', volume: 0.55);
  }

  Future<void> playMove() async {
    await playEffect('audio/block_move.wav', volume: 0.65);
  }

  Future<void> playInvalidMove() async {
    await playEffect('audio/invalid_move.wav', volume: 0.55);
  }

  Future<void> playWin() async {
    await playEffect('audio/level_win.wav', volume: 0.75);
  }

  Future<void> playHint() async {
    await playEffect('audio/hint.wav', volume: 0.55);
  }

  Future<void> playEffect(String assetPath, {double volume = 1.0}) async {
    if (!soundEnabled) {
      return;
    }
    final AudioPlayer player = _sfxPlayers[_sfxIndex];
    _sfxIndex = (_sfxIndex + 1) % _sfxPlayers.length;
    try {
      await player.stop();
      await player.play(
        AssetSource(assetPath),
        volume: volume,
      );
    } catch (_) {
      // Ignore transient audio errors so gameplay never breaks.
    }
  }
}
