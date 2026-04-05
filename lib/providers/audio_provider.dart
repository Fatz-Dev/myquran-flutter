import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../data/local/preferences_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final PreferencesService _prefs;

  String _selectedQariId = '05';
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _currentUrl;
  String _currentTitle = '';
  String _currentSubtitle = '';
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _error;

  AudioProvider(this._prefs) {
    _selectedQariId = _prefs.getSelectedQari();
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
      }
      notifyListeners();
    });
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('AudioSession error: $e');
    }
  }

  String get selectedQariId => _selectedQariId;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get hasAudio => _currentUrl != null;
  String get currentTitle => _currentTitle;
  String get currentSubtitle => _currentSubtitle;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get error => _error;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  Future<void> playAudio({
    required String url,
    required String title,
    required String subtitle,
  }) async {
    if (url.isEmpty) return;
    try {
      _error = null;
      if (_currentUrl != url) {
        _currentUrl = url;
        _currentTitle = title;
        _currentSubtitle = subtitle;
        _isLoading = true;
        notifyListeners();
        await _player.setAudioSource(AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            album: 'MyQuran',
            title: title,
            artist: subtitle,
          ),
        ));
      }
      await _player.play();
    } catch (e, stackTrace) {
      debugPrint('AUDIO ERROR: $e');
      debugPrint('STACKTRACE: $stackTrace');
      _error = 'Gagal memutar: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
    _currentTitle = '';
    _currentSubtitle = '';
    notifyListeners();
  }

  Future<void> seekTo(double progress) async {
    final ms = (_duration.inMilliseconds * progress).toInt();
    await _player.seek(Duration(milliseconds: ms));
  }

  Future<void> setQari(String qariId) async {
    _selectedQariId = qariId;
    await _prefs.setSelectedQari(qariId);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
