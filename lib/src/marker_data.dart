class MarkerData {
  final String label;
  final String assetName;
  final double latitude;
  final double longitude;
  final double width;
  final double height;
  final Function? onTap;

  MarkerData(
      {required this.latitude,
      required this.longitude,
      this.assetName = "",
      this.label = "",
      this.width = 16,
      this.height = 16,
      this.onTap});
}
