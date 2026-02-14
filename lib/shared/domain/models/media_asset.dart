enum MediaType { image, video, file }

class MediaAsset {
  const MediaAsset({
    required this.url,
    this.type = MediaType.image,
    this.width,
    this.height,
  });

  final String url;
  final MediaType type;
  final int? width;
  final int? height;
}
