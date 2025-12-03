import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audio_session/audio_session.dart';
import '../../core/models/component.dart';
import 'fullscreen_video_page.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool loop;
  final bool muted;
  final double height;
  final double padding;
  
  static final Map<String, GlobalKey<_VideoWidgetState>> _stateKeys = {};

  const VideoWidget({
    super.key,
    required this.url,
    required this.autoPlay,
    required this.loop,
    this.muted = false,
    required this.height,
    required this.padding,
  });

  static GlobalKey<_VideoWidgetState> _getStateKey(String url) {
    if (!_stateKeys.containsKey(url)) {
      _stateKeys[url] = GlobalKey<_VideoWidgetState>();
      print('Created new GlobalKey for video URL: $url');
    } else {
      print('Reusing existing GlobalKey for video URL: $url');
    }
    return _stateKeys[url]!;
  }

  factory VideoWidget.fromComponent(Component component, {Key? key}) {
    final props = component.properties;
    final url = props['url'] as String? ?? '';
    final stateKey = url.isNotEmpty ? VideoWidget._getStateKey(url) : null;
    return VideoWidget(
      key: stateKey ?? key,
      url: url,
      autoPlay: props['autoPlay'] as bool? ?? false,
      loop: props['loop'] as bool? ?? false,
      muted: props['muted'] as bool? ?? false,
      height: (props['height'] as num?)?.toDouble() ?? 200,
      padding: (props['padding'] as num?)?.toDouble() ?? 12,
    );
  }

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isDisposing = false;
  bool _isDisposed = false;
  bool _isInFullscreen = false;
  final GlobalKey _chewieKey = GlobalKey();
  Widget? _cachedChewieWidget; 
  final ValueNotifier<bool> _showFullscreenButtonNotifier = ValueNotifier<bool>(true); 
  Timer? _hideFullscreenButtonTimer;
  Timer? _playingStateCheckTimer;
  bool _lastPlayingState = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('VideoWidget initState called for URL: ${widget.url}');
    print('VideoWidget key: ${widget.key}');
    print('Video controller already exists: ${_videoPlayerController != null}');
    print('Video controller initialized: ${_videoPlayerController?.value.isInitialized}');
    print('Chewie controller already exists: ${_chewieController != null}');
    print('Cached widget exists: ${_cachedChewieWidget != null}');
    
    WidgetsBinding.instance.addObserver(this);
    
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      print('Video already initialized in reused state - skipping initialization');
      if (_cachedChewieWidget == null && _chewieController != null) {
        print('Rebuilding cached widget for reused state');
        _buildChewieWidget();
      } else {
        print('State reused with existing controllers and cached widget - no action needed');
      }
    } else if (widget.url.isNotEmpty) {
      print('Initializing new video');
    _initializeVideo();
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }
  
  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('VideoWidget didUpdateWidget called - URL changed: ${oldWidget.url != widget.url}');
    print('Video controller state: ${_videoPlayerController?.value.isInitialized}');
    print('Cached widget state: ${_cachedChewieWidget != null}');
    
    if (oldWidget.url != widget.url && widget.url.isNotEmpty) {
      print('URL changed, reinitializing video');
      _cachedChewieWidget = null; 
      _initializeVideo();
    } else if (_videoPlayerController != null && 
               _videoPlayerController!.value.isInitialized) {
      if (_cachedChewieWidget == null) {
        print('Video initialized but cache missing - rebuilding cache');
        _buildChewieWidget();
      } else {
        print('Widget updated, video initialized, cache exists - keeping everything');
      }
    } else {
      print('Widget updated but video not initialized yet');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_videoPlayerController != null && 
        _videoPlayerController!.value.isInitialized &&
        !_isDisposing &&
        !_isDisposed) {
      if (state == AppLifecycleState.paused || 
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached) {
        _videoPlayerController!.pause();
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    
    if (_videoPlayerController != null && 
        _videoPlayerController!.value.isInitialized &&
        _chewieController != null) {
      print('Video already initialized, skipping reinitialization');
      return;
    }
    
    print('Initializing video for URL: ${widget.url}');
    
    try {
      try {
        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.moviePlayback,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.movie,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ));
        await session.setActive(true);
      } catch (e) {
        print('Audio session configuration warning: $e');
      }

      if (!mounted) return;
      
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _videoPlayerController!.initialize();
      
      if (!mounted) {
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
        return;
      }
      
      await _videoPlayerController!.setVolume(widget.muted ? 0.0 : 1.0);
      
      if (!mounted) {
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
        return;
      }
      
      _videoPlayerController!.addListener(_onVideoPlayerUpdate);

      if (!mounted) {
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
        return;
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: widget.loop,
        allowMuting: true,
        allowFullScreen: false, 
        allowPlaybackSpeedChanging: true,
        showControls: true,
        showControlsOnInitialize: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        fullScreenByDefault: false,
        hideControlsTimer: const Duration(seconds: 3),
        placeholder: Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.videocam, size: 50, color: Colors.grey),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Container(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            height: widget.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video Error',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              _buildChewieWidget();
              setState(() {});
              
              _startPeriodicPlayingStateCheck();
            } catch (e) {
            }
          }
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              setState(() {
                _hasError = true;
              });
            } catch (e) {
            }
          }
        });
      }
    }
  }
  
  void _buildChewieWidget() {
    if (_chewieController == null || _videoPlayerController == null) {
      _cachedChewieWidget = null;
      return;
    }
    
    _cachedChewieWidget = RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: SizedBox.expand(
          child: Chewie(
            key: _chewieKey,
            controller: _chewieController!,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFullscreenButton() {
    return Positioned(
      top: 8,
      left: 8,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showFullscreenButtonNotifier,
        builder: (context, showButton, child) {
          print('🎨 Building button with visibility: $showButton');
          return AnimatedOpacity(
            opacity: showButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !showButton,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openFullscreen,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildChewieWidgetOrCached() {
    if (_cachedChewieWidget != null) {
      print('Returning cached Chewie widget - preventing reload');
      print('Video controller state: initialized=${_videoPlayerController?.value.isInitialized}, playing=${_videoPlayerController?.value.isPlaying}');
      return _cachedChewieWidget!;
    }
    
    print('Building new Chewie widget (first time)');
    if (_chewieController != null && _videoPlayerController != null) {
      _buildChewieWidget();
    }
    
    if (_cachedChewieWidget != null) {
      return _cachedChewieWidget!;
    }
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _onVideoPlayerUpdate() {
    if (!mounted || _isDisposing) return;
    
    try {
      if (_videoPlayerController != null && 
          _videoPlayerController!.value.isPlaying &&
          !widget.muted) {
        final controller = _videoPlayerController;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && controller != null && !_isDisposing) {
            try {
              controller.setVolume(1.0);
            } catch (e) {
            }
          }
        });
      }
      
      if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
        final isPlaying = _videoPlayerController!.value.isPlaying;
        
        if (isPlaying != _lastPlayingState) {
          _lastPlayingState = isPlaying;
        }
        
        if (mounted && !_isDisposing) {
          try {
            if (isPlaying != _lastPlayingState) {
              _lastPlayingState = isPlaying;
              
              if (isPlaying) {
                print('▶️ Listener: Video started playing - starting hide timer');
                _startHideFullscreenButtonTimer();
              } else {
                print('⏸️ Listener: Video paused - showing button');
                _hideFullscreenButtonTimer?.cancel();
                print('⏸️ Listener: Current button visibility: ${_showFullscreenButtonNotifier.value}');
                _showFullscreenButtonNotifier.value = true;
                print('⏸️ Listener: Button visibility set to: ${_showFullscreenButtonNotifier.value}');
              }
            }
          } catch (e) {
            print('Error in listener: $e');
          }
        }
      }
    } catch (e) {
    }
  }
  
  void _startPeriodicPlayingStateCheck() {
    _playingStateCheckTimer?.cancel();
    
    if (_videoPlayerController != null && 
        _videoPlayerController!.value.isInitialized) {
      final isPlaying = _videoPlayerController!.value.isPlaying;
      _lastPlayingState = isPlaying;
      
      if (isPlaying) {
        print('▶️ Video is already playing on init - starting hide timer');
        _startHideFullscreenButtonTimer();
      } else {
        print('⏸️ Video is paused on init - showing button');
        print('⏸️ Init: Current button visibility: ${_showFullscreenButtonNotifier.value}');
        _showFullscreenButtonNotifier.value = true;
        print('⏸️ Init: Button visibility set to: ${_showFullscreenButtonNotifier.value}');
      }
    }
    
    _playingStateCheckTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted || _isDisposing || _videoPlayerController == null) {
        timer.cancel();
        return;
      }
      
      if (!_videoPlayerController!.value.isInitialized) {
        return;
      }
      
      final isPlaying = _videoPlayerController!.value.isPlaying;
      
      if (mounted && !_isDisposing) {
        try {
          if (isPlaying != _lastPlayingState) {
            _lastPlayingState = isPlaying;
            
            if (isPlaying) {
              print('Video started playing - starting hide timer');
              _startHideFullscreenButtonTimer();
            } else {
              print('⏸Video paused - showing button');
              _hideFullscreenButtonTimer?.cancel();
              print('Current button visibility: ${_showFullscreenButtonNotifier.value}');
              _showFullscreenButtonNotifier.value = true;
              print('Button visibility set to: ${_showFullscreenButtonNotifier.value}');
            }
          } else if (isPlaying && _showFullscreenButtonNotifier.value) {
            if (_hideFullscreenButtonTimer == null || !_hideFullscreenButtonTimer!.isActive) {
              print('Video playing, button visible, timer not active - restarting timer');
              _startHideFullscreenButtonTimer();
            }
          } else if (!isPlaying && !_showFullscreenButtonNotifier.value) {
            print('Video paused, button hidden - showing button');
            _hideFullscreenButtonTimer?.cancel();
            _showFullscreenButtonNotifier.value = true;
            print('Button visibility set to: ${_showFullscreenButtonNotifier.value}');
          }
        } catch (e) {
          print('Error in periodic check: $e');
        }
      }
    });
  }
  
  void _onVideoTap() {
    if (!mounted || _isDisposing || _videoPlayerController == null) return;
    
    if (!_videoPlayerController!.value.isInitialized) return;
    
    final isPlaying = _videoPlayerController!.value.isPlaying;
    
    print('👆 Video tapped - showing fullscreen button only');
    _showFullscreenButtonNotifier.value = true;
    
    if (isPlaying) {
      print('👆 Video is playing - starting hide timer after tap');
      _startHideFullscreenButtonTimer();
    }
  }
  
  void _startHideFullscreenButtonTimer() {
    if (_videoPlayerController == null || 
        !_videoPlayerController!.value.isInitialized ||
        !_videoPlayerController!.value.isPlaying) {
      print('⚠️ Not starting timer - video not playing or not initialized');
      return;
    }
    
    _hideFullscreenButtonTimer?.cancel();
    
    print('Starting hide timer for fullscreen button (video is playing)');
    
    _hideFullscreenButtonTimer = Timer(const Duration(seconds: 3), () {
      print('Hide timer fired!');
      if (!mounted || _isDisposing || _videoPlayerController == null) {
        print('Not hiding - widget not mounted or disposing');
        return;
      }
      
      if (_videoPlayerController!.value.isInitialized && 
          _videoPlayerController!.value.isPlaying) {
        try {
          print('Hiding fullscreen button - video is playing');
          _showFullscreenButtonNotifier.value = false;
          print('Button visibility set to: ${_showFullscreenButtonNotifier.value}');
        } catch (e) {
          print('Error hiding button: $e');
        }
      } else {
        print('Not hiding - video not playing or not initialized');
      }
    });
  }

  void _openFullscreen() {
    if (_videoPlayerController == null || 
        !_videoPlayerController!.value.isInitialized ||
        _isDisposing ||
        _isDisposed ||
        _isInFullscreen) {
      return;
    }

    _isInFullscreen = true;

    final videoController = _videoPlayerController!;
    final isPlaying = videoController.value.isPlaying;
    final isMuted = videoController.value.volume == 0.0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPage(
          videoController: videoController,
          isPlaying: isPlaying,
          isMuted: isMuted,
          onExit: () {
            print('onExit callback called');
            print('Video controller before exit: ${_videoPlayerController?.value.isInitialized}');
            if (mounted && !_isDisposing) {
              _isInFullscreen = false;
              print('_isInFullscreen set to false (without setState)');
              print('Video controller after exit flag: ${_videoPlayerController?.value.isInitialized}');
            } else {
              print('WARNING: Widget not mounted or disposing during onExit!');
            }
          },
          onPlayPause: (play) {
          },
          onMuteToggle: (mute) {
          },
          onSeek: (position) {
            if (videoController.value.isInitialized && !_isDisposing) {
              try {
                videoController.seekTo(Duration(seconds: position.toInt()));
              } catch (e) {
              }
            }
          },
        ),
        fullscreenDialog: true,
      ),
    ).then((_) {
      print('Returned from fullscreen, video should continue playing');
      print('Video controller initialized: ${_videoPlayerController?.value.isInitialized}');
      print('Video controller playing: ${_videoPlayerController?.value.isPlaying}');
      print('Video position: ${_videoPlayerController?.value.position}');
      print('Mounted: $mounted, Disposing: $_isDisposing, Disposed: $_isDisposed');
      
      if (mounted && 
          !_isDisposing && 
          !_isDisposed &&
          _videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized) {
        print('Video controller is valid, ensuring it continues playing');
      } else {
        print('WARNING: Video controller is invalid after fullscreen return!');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isDisposed) return;
    
    _isDisposing = true;
    _isDisposed = true;
    
    _hideFullscreenButtonTimer?.cancel();
    _hideFullscreenButtonTimer = null;
    _playingStateCheckTimer?.cancel();
    _playingStateCheckTimer = null;
    
    _showFullscreenButtonNotifier.dispose();
    
    _cachedChewieWidget = null;
    
    try {
      _videoPlayerController?.removeListener(_onVideoPlayerUpdate);
    } catch (e) {
    }
    
    final chewie = _chewieController;
    _chewieController = null;
    
    Future.microtask(() {
      try {
        chewie?.dispose();
      } catch (e) {
      }
    });
    
    if (_videoPlayerController != null && chewie == null) {
      Future.microtask(() {
        try {
          _videoPlayerController?.dispose();
        } catch (e) {
        }
      });
    }
    _videoPlayerController = null;
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (_isDisposing || _isDisposed) {
      return Container(
        height: widget.height,
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      );
    }
    
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.padding),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox.expand(
                  child: _hasError
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  size: 50,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Video Error',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : (_chewieController != null &&
                              _videoPlayerController != null &&
                              !_isDisposing &&
                              !_isDisposed &&
                              _videoPlayerController!.value.isInitialized)
                          ? Listener(
                              onPointerDown: (event) {
                                _onVideoTap();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildChewieWidgetOrCached(),
                                  _buildFullscreenButton(),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
