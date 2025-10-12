# 📊 Finanlzr - Intelligent Stock Analysis Platform

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

**A sophisticated cross-platform financial analysis application with real-time web scraping, AI-powered predictions, and comprehensive stock market insights.**

[Features](#-key-features) • [Tech Stack](#-technical-stack) • [Architecture](#-architecture-highlights) • [Installation](#-installation) • [Screenshots](#-screenshots)

</div>

---

## 👨‍💻 About This Project

**Finanlzr** is a production-ready financial analysis platform built with modern mobile development practices. This project demonstrates expertise in **Flutter development**, **state management**, **RESTful API integration**, **web scraping**, **data visualization**, and **clean architecture patterns**.

### 🎯 Built By

**Subhrajyoti Sahoo** - Full Stack Flutter Developer  
📧 [Email](mailto:subhrajyoti.sahoo@example.com) | 💼 [LinkedIn](https://linkedin.com/in/subhrajyoti5) | 🐙 [GitHub](https://github.com/subhrajyoti5)

---

## 🚀 Key Features

### 📈 Advanced Stock Analysis
- **Real-Time Data Scraping**: Custom-built web scraper for Screener.in with intelligent HTML parsing
- **Multi-Source Integration**: Yahoo Finance API for international stocks, Screener.in for Indian markets
- **Comprehensive Financial Data**: Quarterly results, P&L statements, balance sheets, cash flow, ratios, shareholding patterns
- **Peer Comparison**: Side-by-side analysis of competing companies

### 🤖 AI-Powered Insights
- **LSTM-Based Predictions**: Machine learning model for 7-day price forecasting
- **Sentiment Analysis**: AI-powered market sentiment evaluation
- **Pattern Recognition**: Historical trend analysis with candlestick charts

### 💎 Professional UI/UX
- **Material Design 3**: Modern, polished interface with custom theming
- **Interactive Charts**: fl_chart integration with zoom, pan, and detailed tooltips
- **Responsive Layout**: Optimized for all screen sizes (mobile, tablet, desktop)
- **Dark Mode Support**: Eye-friendly theme switching
- **Expandable Sections**: Clean data presentation with collapsible financial statements

### 🏗️ Technical Excellence
- **State Management**: Riverpod 2.6+ for scalable, testable state architecture
- **Clean Code**: SOLID principles, separation of concerns, modular design
- **Error Handling**: Robust exception handling with user-friendly error messages
- **Smart Caching**: Reduces API calls and improves performance
- **Type Safety**: Leverages Dart's strong typing system

---

## 🛠️ Technical Stack

### Frontend
```yaml
Flutter 3.24+                    # Cross-platform UI framework
Dart 3.5+                        # Programming language
flutter_riverpod ^2.6.1          # State management
go_router ^14.8.1                # Declarative routing
fl_chart ^0.68.0                 # Interactive charts & data visualization
```

### Backend Integration
```yaml
http ^1.2.2                      # REST API client
html ^0.15.4                     # HTML parsing for web scraping
flutter_dotenv ^5.2.1            # Environment configuration
```

### Architecture
- **Provider Pattern**: Centralized state management with Riverpod
- **Service Layer**: Abstracted API and scraping services
- **Model-View-ViewModel**: Clean separation of business logic and UI
- **Repository Pattern**: Data source abstraction

---

## 🏛️ Architecture Highlights

### Project Structure
```
lib/
├── core/
│   ├── services/              # API clients, web scrapers
│   ├── providers/             # Global providers
│   └── constants/             # App-wide constants
├── features/
│   ├── home/                  # Home screen & search
│   ├── results/               # Analysis results & insights
│   │   ├── models/           # Data models
│   │   ├── providers/        # Feature-specific state
│   │   ├── screens/          # UI screens
│   │   └── widgets/          # Reusable components
│   └── portfolio/            # Portfolio management
└── main.dart                  # App entry point
```

### Key Technical Implementations

#### 1. **Intelligent Web Scraping**
```dart
// Custom HTML parser with robust error handling
- h2/h3 header detection for section identification
- DOM tree navigation (parent/sibling traversal)
- Table validation to ensure correct data extraction
- Filtering logic for clean data (removes "compounded" rows, headers)
```

#### 2. **Multi-Source Data Integration**
```dart
// Detects stock type and routes to appropriate API
if (isIndianStock(ticker)) {
  // Screener.in for fundamentals + Yahoo Finance for prices
} else {
  // Yahoo Finance for international stocks/crypto
}
```

#### 3. **State Management with Riverpod**
```dart
// Type-safe, testable state management
final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>
- Automatic UI updates on state changes
- Easy testing and debugging
- Memory-efficient state disposal
```

#### 4. **Responsive UI Design**
```dart
// Adaptive layouts for all screen sizes
- ExpansionTile for collapsible sections
- Custom cards with gradient containers
- Icon-based categorization (strengths vs concerns)
- Professional color schemes and typography
```

---

## 🎨 Key Screens & Features

### 1. Home Screen
- Smart search with auto-detection of Indian vs International stocks
- Recent searches history
- Quick access to portfolio

### 2. Results Screen
- Price chart with candlestick visualization
- AI-powered prediction graphs
- Sentiment analysis indicators
- Quick action buttons

### 3. Detailed Insights Screen (Analytics)
- **Company Overview**: Price, market cap, about company (cleaned & formatted)
- **Key Metrics**: ROE, P/E ratio, market cap, revenue, profit
- **Key Highlights**: Categorized as Strengths (green) vs Concerns (orange)
- **Quarterly Results**: 12 quarters of financial data
- **Profit & Loss**: Historical income statement data
- **Balance Sheet**: Assets, liabilities, equity trends
- **Cash Flow**: Operating, investing, financing cash flows
- **Ratios**: Financial health indicators
- **Shareholding Pattern**: Promoter, FII, DII, public holdings
- **Peer Comparison**: Industry competitors analysis

---

## 💻 Installation

### Prerequisites
- Flutter SDK 3.24 or higher
- Dart SDK 3.5 or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/subhrajyoti5/finanlzr.git
cd finanlzr

# 2. Install dependencies
flutter pub get

# 3. Create environment file (optional)
# Create .env file in root directory for API keys
# COINBASE_API_KEY=your_api_key_here

# 4. Run the app
flutter run

# 5. Build for production
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build web --release          # Web
```

### Supported Platforms
- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Windows Desktop
- ✅ macOS Desktop
- ✅ Linux Desktop

---

## 📸 Screenshots

<div align="center">
  <img src="screenshots/home.png" width="250" alt="Home Screen"/>
  <img src="screenshots/results.png" width="250" alt="Results Screen"/>
  <img src="screenshots/insights.png" width="250" alt="Insights Screen"/>
</div>

---

## 🔧 Technical Challenges Solved

### Problem 1: Web Scraping Reliability
**Challenge**: Screener.in has dynamic HTML structure without stable CSS classes  
**Solution**: Implemented text-based section detection with h2/h3 headers, DOM tree navigation, and table content validation

### Problem 2: Duplicate Data Extraction
**Challenge**: Multiple financial sections showed identical data due to incorrect table selection  
**Solution**: Added strict header validation with keywords (sales, profit, assets, cash, etc.) and proper sibling traversal

### Problem 3: State Management Complexity
**Challenge**: Managing complex async data flows across multiple screens  
**Solution**: Implemented Riverpod with StateNotifier pattern, centralized state, and proper error handling

### Problem 4: UI Performance with Large Datasets
**Challenge**: Rendering hundreds of financial data points caused lag  
**Solution**: Used ExpansionTile for lazy loading, optimized list rendering, and implemented data pagination

---

## 🧪 Code Quality

- ✅ **Clean Architecture**: Separation of concerns with layers (UI, Business Logic, Data)
- ✅ **SOLID Principles**: Single responsibility, dependency injection
- ✅ **Type Safety**: Leverages Dart's null safety features
- ✅ **Error Handling**: Try-catch blocks with user-friendly error messages
- ✅ **Code Documentation**: Inline comments and function documentation
- ✅ **Modular Design**: Reusable components and services

---

## 🚀 Future Enhancements

- [ ] Unit & Integration Tests (target: 80%+ coverage)
- [ ] Real-time WebSocket integration for live prices
- [ ] Push notifications for price alerts
- [ ] Multiple portfolio support
- [ ] Advanced charting (technical indicators: RSI, MACD, Bollinger Bands)
- [ ] Export reports to PDF/Excel
- [ ] Social features (share insights, follow analysts)
- [ ] Machine learning model fine-tuning with user feedback

---

## 📊 Project Statistics

- **Lines of Code**: ~5,000+ (excluding generated files)
- **Screens**: 6 major screens
- **Custom Widgets**: 20+ reusable components
- **API Integrations**: 3 (Yahoo Finance, Screener.in, Custom ML service)
- **State Providers**: 5+ with comprehensive state management
- **Development Time**: 40+ hours of active development

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact

**Subhrajyoti Sahoo**

- 📧 Email: subhrajyoti.sahoo@example.com
- 💼 LinkedIn: [linkedin.com/in/subhrajyoti5](https://linkedin.com/in/subhrajyoti5)
- 🐙 GitHub: [github.com/subhrajyoti5](https://github.com/subhrajyoti5)
- 🌐 Portfolio: [your-portfolio.com](https://your-portfolio.com)

---

<div align="center">

### ⭐ If you find this project useful, please consider giving it a star!

**Made with ❤️ and Flutter by Subhrajyoti Sahoo**

</div>
