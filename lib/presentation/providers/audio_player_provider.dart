import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart' as audio_service;
import '../../data/models/song.dart';
import '../../data/models/playlist.dart';

/// Audio player state
class AudioPlayerState {
  final PlaybackState playbackState;
  final Song? currentSong;
  final Playlist? currentPlaylist;
  final List<Song> queue;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final bool isLoading;
  final String? error;

  AudioPlayerState({
    this.playbackState = PlaybackState.stopped,
    this.currentSong,
    this.currentPlaylist,
    this.queue = const [],
    this.currentIndex = -1,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 0.7,
    this.isShuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.isLoading = false,
    this.error,
  });

  AudioPlayerState copyWith({
    PlaybackState? playbackState,
    Song? currentSong,
    Playlist? currentPlaylist,
    List<Song>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
    bool? isLoading,
    String? error,
  }) {
    return AudioPlayerState(
      playbackState: playbackState ?? this.playbackState,
      currentSong: currentSong ?? this.currentSong,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  double get progress {
    return duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;
  }

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;

  Song? get nextSong => hasNext ? queue[currentIndex + 1] : null;
  Song? get previousSong => hasPrevious ? queue[currentIndex - 1] : null;
}

/// Audio player notifier
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _audioPlayer;

  AudioPlayerNotifier(this._audioPlayer) : super(AudioPlayerState()) {
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.playbackEventStream.listen((event) {
      state = state.copyWith(
        playbackState: _mapPlaybackState(event.processingState),
        position: event.updatePosition,
        duration: _audioPlayer.duration ?? Duration.zero,
      );
    });

    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _audioPlayer.durationStream.listen((duration) {
      state = state.copyWith(duration: duration ?? Duration.zero);
    });
  }

  PlaybackState _mapPlaybackState(ProcessingState processingState) {
    switch (processingState) {
      case ProcessingState.idle:
        return PlaybackState.stopped;
      case ProcessingState.loading:
        return PlaybackState.loading;
      case ProcessingState.buffering:
        return PlaybackState.buffering;
      case ProcessingState.ready:
        return _audioPlayer.playing ? PlaybackState.playing : PlaybackState.paused;
      case ProcessingState.completed:
        return PlaybackState.stopped;
    }
  }

  /// Play a single song
  Future<void> playSong(Song song) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(song.filePath)));
      await _audioPlayer.play();
      state = state.copyWith(
        currentSong: song,
        queue: [song],
        currentIndex: 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to play song: ${e.toString()}',
      );
    }
  }

  /// Play a playlist starting from a specific song
  Future<void> playPlaylist(Playlist playlist, List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final audioSources = songs.map((song) =>
        AudioSource.uri(Uri.file(song.filePath))
      ).toList();

      final playlistSource = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.setAudioSource(playlistSource, initialIndex: startIndex);
      await _audioPlayer.play();

      state = state.copyWith(
        currentPlaylist: playlist,
        queue: songs,
        currentIndex: startIndex,
        currentSong: songs[startIndex],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to play playlist: ${e.toString()}',
      );
    }
  }

  /// Play/pause toggle
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Skip to next song
  Future<void> skipToNext() async {
    if (state.hasNext) {
      await _audioPlayer.seekToNext();
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        currentSong: state.queue[state.currentIndex + 1],
      );
    }
  }

  /// Skip to previous song
  Future<void> skipToPrevious() async {
    if (state.hasPrevious) {
      await _audioPlayer.seekToPrevious();
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        currentSong: state.queue[state.currentIndex - 1],
      );
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  /// Toggle shuffle
  void toggleShuffle() {
    state = state.copyWith(isShuffleEnabled: !state.isShuffleEnabled);
    _audioPlayer.setShuffleModeEnabled(state.isShuffleEnabled);
  }

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    state = state.copyWith(repeatMode: mode);

    switch (mode) {
      case RepeatMode.off:
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.one:
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    state = state.copyWith(
      playbackState: PlaybackState.stopped,
      currentSong: null,
      currentIndex: -1,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Audio player provider
final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final audioPlayer = AudioPlayer();
  return AudioPlayerNotifier(audioPlayer);
});

/// Current song provider (convenience)
final currentSongProvider = Provider<Song?>((ref) {
  return ref.watch(audioPlayerProvider).currentSong;
});

/// Playback state provider (convenience)
final playbackStateProvider = Provider<PlaybackState>((ref) {
  return ref.watch(audioPlayerProvider).playbackState;
});

/// Audio position provider (convenience)
final audioPositionProvider = Provider<AudioPosition>((ref) {
  final state = ref.watch(audioPlayerProvider);
  return AudioPosition(
    current: state.position,
    total: state.duration,
  );
});