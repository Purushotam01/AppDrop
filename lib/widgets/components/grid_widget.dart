import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/component.dart';

class GridImageWidget extends StatefulWidget {
  final String imageUrl;
  final int index;

  const GridImageWidget({
    super.key,
    required this.imageUrl,
    required this.index,
  });

  @override
  State<GridImageWidget> createState() => _GridImageWidgetState();
}

class _GridImageWidgetState extends State<GridImageWidget> {
  bool _useFallback = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (widget.imageUrl.isEmpty) {
      return Container(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: isDarkMode ? Colors.grey[400] : Colors.grey,
            size: 40,
          ),
        ),
      );
    }

    if (!_useFallback && !_hasError) {
      return CachedNetworkImage(
        key: ValueKey('grid_image_${widget.index}_${widget.imageUrl}'),
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
        httpHeaders: const {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        },
        maxWidthDiskCache: 1000,
        maxHeightDiskCache: 1000,
        placeholder: (context, url) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Container(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
              ),
            ),
          );
        },
        errorWidget: (context, url, error) {
          print('CachedNetworkImage error for index ${widget.index}, URL: $url, Error: $error');
          if (!_useFallback) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _useFallback = true;
                });
              }
            });
          }
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Container(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
              ),
            ),
          );
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      );
    }

    return Image.network(
      widget.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Image.network error for index ${widget.index}: $error');
        final errorString = error.toString();
        if (errorString.contains('404') || errorString.contains('statusCode')) {
          print('Image URL not found (404) for: ${widget.imageUrl}');
        }
        if (!_hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          });
        }
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}

class GridWidget extends StatelessWidget {
  final List<String> images;
  final int columns;
  final double spacing;
  final double padding;

  const GridWidget({
    super.key,
    required this.images,
    required this.columns,
    required this.spacing,
    required this.padding,
  });

  factory GridWidget.fromComponent(Component component) {
    final props = component.properties;
    
    final imagesList = props['images'];
    List<String> images = [];
    
    if (imagesList != null) {
      if (imagesList is List) {
        images = imagesList
            .map((e) => e?.toString() ?? '')
            .where((url) => url.isNotEmpty && url.startsWith('http'))
            .toList();
      }
    }
    
    print('GridWidget: Parsed ${images.length} images from JSON');
    for (int i = 0; i < images.length; i++) {
      print('  Image ${i + 1}: ${images[i]}');
    }
    
    return GridWidget(
      images: images,
      columns: props['columns'] as int? ?? 2,
      spacing: (props['spacing'] as num?)?.toDouble() ?? 12,
      padding: (props['padding'] as num?)?.toDouble() ?? 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index];
          print('Grid building item ${index + 1} with URL: $imageUrl');
          
          return Container(
            key: ValueKey('grid_item_${index}_$imageUrl'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: imageUrl.isNotEmpty
                        ? GridImageWidget(
                            imageUrl: imageUrl,
                            index: index,
                          )
                        : Container(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : const Color(0xFF333333),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}