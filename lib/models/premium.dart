class Premium {
  String title = "";
  double price = 0.0;
  double saleOff = 0;
  String desc = "";
  String note = "";
  String currencySymbol = "\$";
  String packageId;

  Premium(
      {required this.title,
      required this.price,
      required this.saleOff,
      required this.desc,
      required this.packageId});
}
