class PortfolioStock {
  final String symbol;
  final String name;
  final double? currentPrice;
  final double? changePercent;

  PortfolioStock({
    required this.symbol,
    this.name = '',
    this.currentPrice,
    this.changePercent,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'currentPrice': currentPrice,
    'changePercent': changePercent,
  };

  factory PortfolioStock.fromJson(Map<String, dynamic> json) => PortfolioStock(
    symbol: json['symbol'],
    name: json['name'] ?? '',
    currentPrice: json['currentPrice'],
    changePercent: json['changePercent'],
  );

  PortfolioStock copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? changePercent,
  }) {
    return PortfolioStock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      changePercent: changePercent ?? this.changePercent,
    );
  }
}
