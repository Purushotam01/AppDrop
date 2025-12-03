import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController videoController;
  final bool isPlaying;
  final bool isMuted;
  final VoidCallback onExit;
  final Function(bool) onPlayPause;
  final Function(bool) onMuteToggle;
  final Function(double) onSeek;

  const FullscreenVideoPage({
    super.key,
    required this.videoController,
    required this.isPlaying,
    required this.isMuted,
    required this.onExit,
    required this.onPlayPause,
    required this.onMuteToggle,
    required this.onSeek,
  });

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isMuted = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
    _isMuted = widget.isMuted;
    _updatePosition();
    widget.videoController.addListener(_updatePosition);
    
    _hideControlsTimer();
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    widget.videoController.removeListener(_updatePosition);
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
    }
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
    }
    super.dispose();
  }

  void _updatePosition() {
    if (mounted && !_isDragging && widget.videoController.value.isInitialized) {
      try {
        setState(() {
          _currentPosition = widget.videoController.value.position;
          _totalDuration = widget.videoController.value.duration;
          _isPlaying = widget.videoController.value.isPlaying;
        });
      } catch (e) {
      }
    }
  }

  void _hideControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _hideControlsTimer();
    }
  }

  void _skipBackward() {
    if (!mounted) {
      print('_skipBackward: Not mounted');
      return;
    }
    
    try {
      if (!widget.videoController.value.isInitialized) {
        print('_skipBackward: Controller not initialized');
        return;
      }
      
      final newPosition = _currentPosition - const Duration(seconds: 15);
      final seekPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
      
      print('_skipBackward: Seeking from ${_currentPosition.inSeconds}s to ${seekPosition.inSeconds}s');
      
      widget.videoController.seekTo(seekPosition).then((_) {
        print('_skipBackward: Seek successful');
        setState(() {
          _currentPosition = seekPosition;
        });
      }).catchError((e) {
        print('_skipBackward: Seek error: $e');
      });
      
      widget.onSeek(seekPosition.inMilliseconds.toDouble() / 1000);
    } catch (e) {
      print('Error in _skipBackward: $e');
    }
  }

  void _skipForward() {
    if (!mounted) {
      print('_skipForward: Not mounted');
      return;
    }
    
    try {
      if (!widget.videoController.value.isInitialized) {
        print('_skipForward: Controller not initialized');
        return;
      }
      
      final newPosition = _currentPosition + const Duration(seconds: 15);
      final seekPosition = newPosition > _totalDuration ? _totalDuration : newPosition;
      
      print('_skipForward: Seeking from ${_currentPosition.inSeconds}s to ${seekPosition.inSeconds}s');
      
      widget.videoController.seekTo(seekPosition).then((_) {
        print('_skipForward: Seek successful');
        setState(() {
          _currentPosition = seekPosition;
        });
      }).catchError((e) {
        print('_skipForward: Seek error: $e');
      });
      
      widget.onSeek(seekPosition.inMilliseconds.toDouble() / 1000);
    } catch (e) {
      print('Error in _skipForward: $e');
    }
  }

  void _togglePlayPause() {
    if (!mounted) {
      print('_togglePlayPause: Not mounted');
      return;
    }
    
    try {
      if (!widget.videoController.value.isInitialized) {
        print('_togglePlayPause: Controller not initialized');
        return;
      }
      
      final newPlayingState = !_isPlaying;
      print('_togglePlayPause: Changing state from $_isPlaying to $newPlayingState');
      
      if (newPlayingState) {
        widget.videoController.play().then((_) {
          print('_togglePlayPause: Play successful');
        }).catchError((e) {
          print('_togglePlayPause: Play error: $e');
        });
      } else {
        widget.videoController.pause();
        print('_togglePlayPause: Pause called');
      }
      
      setState(() {
        _isPlaying = newPlayingState;
      });
    } catch (e) {
      print('Error in _togglePlayPause: $e');
    }
  }

  void _toggleMute() {
    if (!mounted) {
      print('_toggleMute: Not mounted');
      return;
    }
    
    try {
      if (!widget.videoController.value.isInitialized) {
        print('_toggleMute: Controller not initialized');
        return;
      }
      
      final newMutedState = !_isMuted;
      final volume = newMutedState ? 0.0 : 1.0;
      print('_toggleMute: Changing volume from ${widget.videoController.value.volume} to $volume');
      
      widget.videoController.setVolume(volume).then((_) {
        print('_toggleMute: Volume set to $volume');
      }).catchError((e) {
        print('_toggleMute: Volume error: $e');
      });
      
      setState(() {
        _isMuted = newMutedState;
      });
    } catch (e) {
      print('Error in _toggleMute: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _handleExit() {
    print('_handleExit called, mounted: $mounted');
    if (!mounted) {
      print('_handleExit: Not mounted, returning');
      return;
    }
    
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      
      final navigator = Navigator.of(context, rootNavigator: false);
      print('Navigator obtained, canPop: ${navigator.canPop()}');
      
      if (navigator.canPop()) {
        print('Popping route now');
        navigator.pop();
        print('Route popped');
      } else {
        print('Cannot pop route');
      }
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          widget.onExit();
        }
      });
    } catch (e) {
      print('Error in _handleExit: $e');
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      widget.onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        print('PopScope onPopInvoked: didPop=$didPop');
        if (!didPop) {
          _handleExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
          children: [
            // Video player
            Center(
              child: widget.videoController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: widget.videoController.value.aspectRatio,
                      child: VideoPlayer(widget.videoController),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
            
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                                onPressed: _handleExit,
                                tooltip: 'Exit Fullscreen',
                              ),
                              Text(
                                'Fullscreen',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 48), 
                            ],
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                            onPressed: _skipBackward,
                            tooltip: 'Skip 15s backward',
                            iconSize: 32,
                          ),
                          const SizedBox(width: 20),
                          
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                              onPressed: _togglePlayPause,
                              tooltip: _isPlaying ? 'Pause' : 'Play',
                              iconSize: 48,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          IconButton(
                            icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                            onPressed: _skipForward,
                            tooltip: 'Skip 15s forward',
                            iconSize: 32,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return GestureDetector(
                                    onHorizontalDragStart: (_) {
                                      setState(() {
                                        _isDragging = true;
                                      });
                                    },
                                    onHorizontalDragEnd: (_) {
                                      setState(() {
                                        _isDragging = false;
                                      });
                                    },
                                    onHorizontalDragUpdate: (details) {
                                      final width = constraints.maxWidth;
                                      final dx = details.localPosition.dx;
                                      final progress = (dx / width).clamp(0.0, 1.0);
                                      final newPosition = Duration(
                                        milliseconds: (_totalDuration.inMilliseconds * progress).toInt(),
                                      );
                                      setState(() {
                                        _currentPosition = newPosition;
                                      });
                                    },
                                    onTapDown: (details) {
                                      final width = constraints.maxWidth;
                                      final dx = details.localPosition.dx;
                                      final progress = (dx / width).clamp(0.0, 1.0);
                                      final newPosition = Duration(
                                        milliseconds: (_totalDuration.inMilliseconds * progress).toInt(),
                                      );
                                      widget.onSeek(newPosition.inMilliseconds.toDouble() / 1000);
                                      setState(() {
                                        _currentPosition = newPosition;
                                        _isDragging = false;
                                      });
                                    },
                                    child: VideoProgressIndicator(
                                      widget.videoController,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: Colors.red,
                                        bufferedColor: Colors.white24,
                                        backgroundColor: Colors.white12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Row(
                                children: [
                                  Text(
                                    '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  
                                  const Spacer(),
                                  
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          _isMuted ? Icons.volume_off : Icons.volume_up,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: _toggleMute,
                                        tooltip: _isMuted ? 'Unmute' : 'Mute',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

