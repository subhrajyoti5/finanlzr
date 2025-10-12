import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:finanlzr/features/results/models/analysis_data.dart';

class ScreenerWebScraperService {
  static const String _baseUrl = 'https://www.screener.in';

  /// Scrapes detailed company information from Screener.in
  Future<Map<String, dynamic>?> scrapeCompanyData(String ticker) async {
    try {
      final url = Uri.parse('$_baseUrl/company/$ticker/');
      print('Scraping data from: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        return _parseCompanyData(document, ticker);
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error scraping company data: $e');
      return null;
    }
  }

  /// Parses the HTML document to extract company data
  Map<String, dynamic> _parseCompanyData(dom.Document document, String ticker) {
    final data = <String, dynamic>{};

    try {
      print('🔍 Starting to parse data for $ticker');

      // Extract company overview
      data['overview'] = _extractCompanyOverview(document);
      print('📋 Overview extracted: ${data['overview']?.keys.join(", ")}');

      // Extract key metrics
      data['keyMetrics'] = _extractKeyMetrics(document);
      print(
        '📊 Key metrics extracted: ${data['keyMetrics']?.keys.length} items',
      );

      // Extract quarterly results
      data['quarterlyResults'] = _extractQuarterlyResults(document);
      print(
        '📈 Quarterly results extracted: ${data['quarterlyResults']?.length} quarters',
      );

      // Extract profit & loss data
      data['profitLoss'] = _extractProfitLoss(document);
      print('💰 P&L extracted: ${data['profitLoss']?.keys.length} items');

      // Extract balance sheet data
      data['balanceSheet'] = _extractBalanceSheet(document);
      print(
        '🏦 Balance sheet extracted: ${data['balanceSheet']?.keys.length} items',
      );

      // Extract cash flow data
      data['cashFlow'] = _extractCashFlow(document);
      print('💸 Cash flow extracted: ${data['cashFlow']?.keys.length} items');

      // Extract ratios
      data['ratios'] = _extractRatios(document);
      print('📊 Ratios extracted: ${data['ratios']?.keys.length} items');

      // Extract shareholding pattern
      data['shareholding'] = _extractShareholding(document);
      print(
        '👥 Shareholding extracted: ${data['shareholding']?.keys.length} categories',
      );

      // Extract peer comparison
      data['peers'] = _extractPeerComparison(document);
      print('🏢 Peers extracted: ${data['peers']?.length} companies');

      print('✅ Successfully parsed data for $ticker');
    } catch (e) {
      print('❌ Error parsing company data: $e');
    }

    return data;
  }

  Map<String, dynamic> _extractCompanyOverview(dom.Document document) {
    final overview = <String, dynamic>{};

    try {
      // Company name - try multiple selectors
      final companyNameElement =
          document.querySelector('h1') ??
          document.querySelector('.company-name') ??
          document.querySelector('[data-company-name]');
      final companyName = companyNameElement?.text?.trim() ?? '';

      // Current price - look for the specific price display
      var priceElement =
          document.querySelector('.current-price') ??
          document.querySelector('[data-current-price]') ??
          document.querySelector('.price') ??
          document.querySelector('[class*="price"]') ??
          document.querySelector('span.price') ??
          document.querySelector('.number') ??
          document.querySelector('strong'); // Price might be in strong tag
      var price = priceElement?.text?.trim() ?? '';

      // About section - look for the about section content
      final aboutElement =
          document.querySelector('.company-info') ??
          document.querySelector('[data-about]') ??
          document.querySelector('.about') ??
          document.querySelector('[class*="about"]') ??
          document.querySelector('.description') ??
          document.querySelector('p.company-description') ??
          document.querySelector(
            'div.about',
          ); // About section might be in div.about
      final about = aboutElement?.text?.trim() ?? '';

      // Market cap - look for the market cap display
      var marketCapElement =
          document.querySelector('[data-market-cap]') ??
          document.querySelector('.market-cap') ??
          document.querySelector('[class*="market"]') ??
          document.querySelector('.market-capitalization') ??
          document.querySelector('span.market-cap') ??
          document.querySelector('strong'); // Market cap might be in strong tag
      var marketCap = marketCapElement?.text?.trim() ?? '';

      // Debug logging
      print('Company Name Element: ${companyNameElement?.text}');
      print('Price Element: ${priceElement?.text}');
      print('About Element: ${aboutElement?.text}');
      print('Market Cap Element: ${marketCapElement?.text}');

      // Fallback: Extract price from text content if selector didn't work
      if (price.isEmpty) {
        final bodyText = document.body?.text ?? '';
        final priceRegex = RegExp(r'₹\s*[\d,]+\.?\d*');
        final priceMatch = priceRegex.firstMatch(bodyText);
        if (priceMatch != null) {
          price = priceMatch.group(0) ?? '';
          print('Price extracted from text: $price');
        }
      }

      // Fallback: Extract market cap from text content
      if (marketCap.isEmpty) {
        final bodyText = document.body?.text ?? '';
        final marketCapRegex = RegExp(r'[\d,]+\.?\d*\s*Cr\.?');
        final marketCapMatch = marketCapRegex.firstMatch(bodyText);
        if (marketCapMatch != null) {
          marketCap = marketCapMatch.group(0) ?? '';
          print('Market cap extracted from text: $marketCap');
        }
      }

      overview['name'] = companyName;
      overview['price'] = price;
      overview['about'] = about;
      overview['marketCap'] = marketCap;

      // Key points
      final keyPoints = <String>[];
      final keyPointElements = document.querySelectorAll(
        '.key-points li, .pros-cons li',
      );
      for (final element in keyPointElements) {
        final text = element.text.trim();
        if (text.isNotEmpty) {
          keyPoints.add(text);
        }
      }

      // Fallback: Extract key points from text content
      if (keyPoints.isEmpty) {
        final allElements = document.querySelectorAll('*');
        for (final element in allElements) {
          final text = element.text?.trim() ?? '';
          if ((text.startsWith('Company has') ||
                  text.startsWith('Stock is') ||
                  text.contains('track record') ||
                  text.contains('growth of')) &&
              text.length > 20 &&
              text.length < 200 &&
              !text.contains('http')) {
            if (!keyPoints.contains(text)) {
              keyPoints.add(text);
              print('Found key point: $text');
            }
          }
        }
      }

      overview['keyPoints'] = keyPoints;
    } catch (e) {
      print('Error extracting company overview: $e');
    }

    return overview;
  }

  Map<String, dynamic> _extractKeyMetrics(dom.Document document) {
    final metrics = <String, dynamic>{};

    try {
      // Extract key ratios and metrics
      final metricElements = document.querySelectorAll(
        '.key-metrics .metric, .ratios .ratio',
      );

      for (final element in metricElements) {
        final label = element.querySelector('.label')?.text?.trim() ?? '';
        final value = element.querySelector('.value')?.text?.trim() ?? '';

        if (label.isNotEmpty && value.isNotEmpty) {
          // Clean up the label to use as key
          final key = label
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll('/', '_')
              .replaceAll('%', 'percent')
              .replaceAll('₹', 'rs');
          metrics[key] = value;
        }
      }

      // Extract specific key metrics from the HTML structure
      // Look for P/E ratio
      final peElements = document.querySelectorAll('*');
      for (final element in peElements) {
        final text = element.text?.trim() ?? '';
        if (text.contains('Stock P/E') || text.contains('P/E')) {
          final peMatch = RegExp(r'(\d+\.?\d*)').firstMatch(text);
          if (peMatch != null) {
            metrics['pe_ratio'] = peMatch.group(1);
            break;
          }
        }
      }

      // Look for Book Value
      for (final element in peElements) {
        final text = element.text?.trim() ?? '';
        if (text.contains('Book Value')) {
          final bvMatch = RegExp(r'₹?\s*([\d,]+\.?\d*)').firstMatch(text);
          if (bvMatch != null) {
            metrics['book_value'] = bvMatch.group(1);
            break;
          }
        }
      }

      // Look for Dividend Yield
      for (final element in peElements) {
        final text = element.text?.trim() ?? '';
        if (text.contains('Dividend Yield')) {
          final dyMatch = RegExp(r'(\d+\.?\d*)').firstMatch(text);
          if (dyMatch != null) {
            metrics['dividend_yield'] = dyMatch.group(1);
            break;
          }
        }
      }

      // Look for ROCE
      for (final element in peElements) {
        final text = element.text?.trim() ?? '';
        if (text.contains('ROCE')) {
          final roceMatch = RegExp(r'(\d+\.?\d*)').firstMatch(text);
          if (roceMatch != null) {
            metrics['roce'] = roceMatch.group(1);
            break;
          }
        }
      }

      // Look for ROE
      for (final element in peElements) {
        final text = element.text?.trim() ?? '';
        if (text.contains('ROE')) {
          final roeMatch = RegExp(r'(\d+\.?\d*)').firstMatch(text);
          if (roeMatch != null) {
            metrics['roe'] = roeMatch.group(1);
            break;
          }
        }
      }
    } catch (e) {
      print('Error extracting key metrics: $e');
    }

    return metrics;
  }

  List<Map<String, dynamic>> _extractQuarterlyResults(dom.Document document) {
    final results = <Map<String, dynamic>>[];

    try {
      // Find section by looking for h2/h3 with specific text
      dom.Element? sectionHeader;
      final headers = document.querySelectorAll('h2, h3, section > header');

      for (final header in headers) {
        final headerText = header.text.trim().toLowerCase();
        if (headerText == 'quarterly results' ||
            headerText.contains('quarterly result')) {
          sectionHeader = header;
          print('📊 Found Quarterly Results header: "${header.text.trim()}"');
          break;
        }
      }

      // If header found, get the table in the same section
      dom.Element? quarterlyTable;
      if (sectionHeader != null) {
        // Look for table in parent section or following siblings
        var current = sectionHeader.parent;
        while (current != null && quarterlyTable == null) {
          quarterlyTable = current.querySelector('table');
          if (quarterlyTable != null) break;
          current = current.parent;
        }

        // If not found in parent, check next siblings
        if (quarterlyTable == null) {
          var sibling = sectionHeader.nextElementSibling;
          while (sibling != null && quarterlyTable == null) {
            if (sibling.localName == 'table') {
              quarterlyTable = sibling;
              break;
            }
            quarterlyTable = sibling.querySelector('table');
            if (quarterlyTable != null) break;
            sibling = sibling.nextElementSibling;
          }
        }
      }

      if (quarterlyTable != null) {
        final rows = quarterlyTable.querySelectorAll('tr');
        print('📊 Found quarterly table with ${rows.length} rows');

        if (rows.length > 1) {
          // Verify it's the right table by checking header
          final headerCells = rows[0].querySelectorAll('th, td');
          final headerText = headerCells
              .map((c) => c.text.trim().toLowerCase())
              .join(' ');
          
          print('📊 Quarterly table header: "$headerText"');

          // More lenient validation - just check if it's not empty and looks like financial data
          if (headerText.isNotEmpty && (headerText.contains('sales') ||
              headerText.contains('revenue') ||
              headerText.contains('quarter') ||
              headerText.contains('mar') ||
              headerText.contains('sep') ||
              headerText.contains('dec') ||
              headerText.contains('jun') ||
              headerCells.length >= 4)) {
            // Process data rows
            for (int i = 1; i < rows.length && i <= 12; i++) {
              // Limit to 12 quarters
              final cells = rows[i].querySelectorAll('td, th');
              if (cells.isNotEmpty) {
                final result = {
                  'quarter': cells.length > 0 ? cells[0].text.trim() : '',
                  'sales': cells.length > 1 ? cells[1].text.trim() : '',
                  'expenses': cells.length > 2 ? cells[2].text.trim() : '',
                  'operating_profit': cells.length > 3
                      ? cells[3].text.trim()
                      : '',
                  'opm_percent': cells.length > 4 ? cells[4].text.trim() : '',
                  'other_income': cells.length > 5 ? cells[5].text.trim() : '',
                  'interest': cells.length > 6 ? cells[6].text.trim() : '',
                  'depreciation': cells.length > 7 ? cells[7].text.trim() : '',
                  'profit_before_tax': cells.length > 8
                      ? cells[8].text.trim()
                      : '',
                  'tax_percent': cells.length > 9 ? cells[9].text.trim() : '',
                  'net_profit': cells.length > 10 ? cells[10].text.trim() : '',
                  'eps': cells.length > 11 ? cells[11].text.trim() : '',
                };
                results.add(result);
              }
            }
            print('✅ Extracted ${results.length} quarterly results');
          } else {
            print('⚠️ Table header doesn\'t match quarterly results format');
          }
        }
      } else {
        print('⚠️ Quarterly Results table not found');
      }
    } catch (e) {
      print('❌ Error extracting quarterly results: $e');
    }

    return results;
  }

  Map<String, dynamic> _extractProfitLoss(dom.Document document) {
    final plData = <String, dynamic>{};

    try {
      // Find section by looking for h2/h3 with specific text
      dom.Element? sectionHeader;
      final headers = document.querySelectorAll('h2, h3, section > header');

      for (final header in headers) {
        final headerText = header.text.trim().toLowerCase();
        if (headerText == 'profit & loss' ||
            headerText == 'profit and loss' ||
            headerText.contains('profit & loss')) {
          sectionHeader = header;
          print('💰 Found Profit & Loss header: "${header.text.trim()}"');
          break;
        }
      }

      dom.Element? plTable;
      if (sectionHeader != null) {
        // Look in parent section
        var current = sectionHeader.parent;
        while (current != null && plTable == null) {
          plTable = current.querySelector('table');
          if (plTable != null) break;
          current = current.parent;
        }

        // Check next siblings
        if (plTable == null) {
          var sibling = sectionHeader.nextElementSibling;
          while (sibling != null && plTable == null) {
            if (sibling.localName == 'table') {
              plTable = sibling;
              break;
            }
            plTable = sibling.querySelector('table');
            if (plTable != null) break;
            sibling = sibling.nextElementSibling;
          }
        }
      }

      if (plTable != null) {
        final rows = plTable.querySelectorAll('tr');
        print('💰 Found P&L table with ${rows.length} rows');

        // Verify it's the right table
        if (rows.isNotEmpty) {
          final firstCells = rows[0].querySelectorAll('th, td');
          final headerText = firstCells
              .map((c) => c.text.trim().toLowerCase())
              .join(' ');

          if (headerText.contains('sales') ||
              headerText.contains('revenue') ||
              headerText.contains('profit') ||
              headerText.contains('mar')) {
            for (final row in rows.skip(1)) {
              // Skip header
              final cells = row.querySelectorAll('td, th');
              if (cells.length >= 2) {
                final label = cells[0].text.trim();
                final values = <String>[];

                for (int i = 1; i < cells.length; i++) {
                  values.add(cells[i].text.trim());
                }

                if (label.isNotEmpty &&
                    label.toLowerCase() != 'particulars' &&
                    !label.toLowerCase().contains('compounded')) {
                  plData[label] = values;
                }
              }
            }
            print('✅ Extracted ${plData.length} P&L items');
          } else {
            print('⚠️ Table header doesn\'t match P&L format');
          }
        }
      } else {
        print('⚠️ P&L table not found');
      }
    } catch (e) {
      print('❌ Error extracting profit & loss data: $e');
    }

    return plData;
  }

  Map<String, dynamic> _extractBalanceSheet(dom.Document document) {
    final bsData = <String, dynamic>{};

    try {
      // Find section by looking for h2/h3 with specific text
      dom.Element? sectionHeader;
      final headers = document.querySelectorAll('h2, h3, section > header');

      for (final header in headers) {
        final headerText = header.text.trim().toLowerCase();
        if (headerText == 'balance sheet' ||
            headerText.contains('balance sheet')) {
          sectionHeader = header;
          print('🏦 Found Balance Sheet header: "${header.text.trim()}"');
          break;
        }
      }

      dom.Element? bsTable;
      if (sectionHeader != null) {
        // Look in parent section
        var current = sectionHeader.parent;
        while (current != null && bsTable == null) {
          bsTable = current.querySelector('table');
          if (bsTable != null) break;
          current = current.parent;
        }

        // Check next siblings
        if (bsTable == null) {
          var sibling = sectionHeader.nextElementSibling;
          while (sibling != null && bsTable == null) {
            if (sibling.localName == 'table') {
              bsTable = sibling;
              break;
            }
            bsTable = sibling.querySelector('table');
            if (bsTable != null) break;
            sibling = sibling.nextElementSibling;
          }
        }
      }

      if (bsTable != null) {
        final rows = bsTable.querySelectorAll('tr');
        print('🏦 Found Balance Sheet table with ${rows.length} rows');

        // Verify it's the right table
        if (rows.isNotEmpty) {
          final firstCells = rows[0].querySelectorAll('th, td');
          final headerText = firstCells
              .map((c) => c.text.trim().toLowerCase())
              .join(' ');

          if (headerText.contains('assets') ||
              headerText.contains('liabilities') ||
              headerText.contains('equity') ||
              headerText.contains('mar')) {
            for (final row in rows.skip(1)) {
              // Skip header
              final cells = row.querySelectorAll('td, th');
              if (cells.length >= 2) {
                final label = cells[0].text.trim();
                final values = <String>[];

                for (int i = 1; i < cells.length; i++) {
                  values.add(cells[i].text.trim());
                }

                if (label.isNotEmpty &&
                    label.toLowerCase() != 'particulars' &&
                    !label.toLowerCase().contains('compounded')) {
                  bsData[label] = values;
                }
              }
            }
            print('✅ Extracted ${bsData.length} balance sheet items');
          } else {
            print('⚠️ Table header doesn\'t match Balance Sheet format');
          }
        }
      } else {
        print('⚠️ Balance Sheet table not found');
      }
    } catch (e) {
      print('❌ Error extracting balance sheet data: $e');
    }

    return bsData;
  }

  Map<String, dynamic> _extractCashFlow(dom.Document document) {
    final cfData = <String, dynamic>{};

    try {
      // Find section by looking for h2/h3 with specific text
      dom.Element? sectionHeader;
      final headers = document.querySelectorAll('h2, h3, section > header');

      for (final header in headers) {
        final headerText = header.text.trim().toLowerCase();
        if (headerText == 'cash flow' ||
            headerText == 'cashflow' ||
            headerText.contains('cash flow')) {
          sectionHeader = header;
          print('💸 Found Cash Flow header: "${header.text.trim()}"');
          break;
        }
      }

      dom.Element? cfTable;
      if (sectionHeader != null) {
        // Look in parent section
        var current = sectionHeader.parent;
        while (current != null && cfTable == null) {
          cfTable = current.querySelector('table');
          if (cfTable != null) break;
          current = current.parent;
        }

        // Check next siblings
        if (cfTable == null) {
          var sibling = sectionHeader.nextElementSibling;
          while (sibling != null && cfTable == null) {
            if (sibling.localName == 'table') {
              cfTable = sibling;
              break;
            }
            cfTable = sibling.querySelector('table');
            if (cfTable != null) break;
            sibling = sibling.nextElementSibling;
          }
        }
      }

      if (cfTable != null) {
        final rows = cfTable.querySelectorAll('tr');
        print('💸 Found Cash Flow table with ${rows.length} rows');

        // Verify it's the right table
        if (rows.isNotEmpty) {
          final firstCells = rows[0].querySelectorAll('th, td');
          final headerText = firstCells
              .map((c) => c.text.trim().toLowerCase())
              .join(' ');

          if (headerText.contains('cash') ||
              headerText.contains('operating') ||
              headerText.contains('investing') ||
              headerText.contains('mar')) {
            for (final row in rows.skip(1)) {
              // Skip header
              final cells = row.querySelectorAll('td, th');
              if (cells.length >= 2) {
                final label = cells[0].text.trim();
                final values = <String>[];

                for (int i = 1; i < cells.length; i++) {
                  values.add(cells[i].text.trim());
                }

                if (label.isNotEmpty &&
                    label.toLowerCase() != 'particulars' &&
                    !label.toLowerCase().contains('compounded')) {
                  cfData[label] = values;
                }
              }
            }
            print('✅ Extracted ${cfData.length} cash flow items');
          } else {
            print('⚠️ Table header doesn\'t match Cash Flow format');
          }
        }
      } else {
        print('⚠️ Cash Flow table not found');
      }
    } catch (e) {
      print('❌ Error extracting cash flow data: $e');
    }

    return cfData;
  }

  Map<String, dynamic> _extractRatios(dom.Document document) {
    final ratios = <String, dynamic>{};

    try {
      // Find section by looking for h2/h3 with specific text
      dom.Element? sectionHeader;
      final headers = document.querySelectorAll('h2, h3, section > header');

      for (final header in headers) {
        final headerText = header.text.trim().toLowerCase();
        if ((headerText == 'ratios' || headerText.contains('ratio')) &&
            !headerText.contains('comparison') &&
            !headerText.contains('peer')) {
          sectionHeader = header;
          print('📊 Found Ratios header: "${header.text.trim()}"');
          break;
        }
      }

      dom.Element? ratiosTable;
      if (sectionHeader != null) {
        // Look in parent section
        var current = sectionHeader.parent;
        while (current != null && ratiosTable == null) {
          ratiosTable = current.querySelector('table');
          if (ratiosTable != null) break;
          current = current.parent;
        }

        // Check next siblings
        if (ratiosTable == null) {
          var sibling = sectionHeader.nextElementSibling;
          while (sibling != null && ratiosTable == null) {
            if (sibling.localName == 'table') {
              ratiosTable = sibling;
              break;
            }
            ratiosTable = sibling.querySelector('table');
            if (ratiosTable != null) break;
            sibling = sibling.nextElementSibling;
          }
        }
      }

      if (ratiosTable != null) {
        final rows = ratiosTable.querySelectorAll('tr');
        print('📊 Found Ratios table with ${rows.length} rows');

        // Verify it's the right table
        if (rows.isNotEmpty) {
          final firstCells = rows[0].querySelectorAll('th, td');
          final headerText = firstCells
              .map((c) => c.text.trim().toLowerCase())
              .join(' ');

          if (headerText.contains('roe') ||
              headerText.contains('roce') ||
              headerText.contains('debtor') ||
              headerText.contains('mar')) {
            for (final row in rows.skip(1)) {
              // Skip header
              final cells = row.querySelectorAll('td, th');
              if (cells.length >= 2) {
                final label = cells[0].text.trim();
                final values = <String>[];

                for (int i = 1; i < cells.length; i++) {
                  values.add(cells[i].text.trim());
                }

                if (label.isNotEmpty &&
                    label.toLowerCase() != 'ratios' &&
                    !label.toLowerCase().contains('compounded')) {
                  ratios[label] = values;
                }
              }
            }
            print('✅ Extracted ${ratios.length} ratio items');
          } else {
            print('⚠️ Table header doesn\'t match Ratios format');
          }
        }
      } else {
        print('⚠️ Ratios table not found');
      }
    } catch (e) {
      print('❌ Error extracting ratios: $e');
    }

    return ratios;
  }

  Map<String, dynamic> _extractShareholding(dom.Document document) {
    final shareholding = <String, dynamic>{};

    try {
      // Find section by looking for h2/h3 with specific text
      dom.Element? sectionHeader;
      final headers = document.querySelectorAll('h2, h3, section > header');

      for (final header in headers) {
        final headerText = header.text.trim().toLowerCase();
        if (headerText.contains('shareholding') ||
            headerText.contains('shareholder')) {
          sectionHeader = header;
          print('👥 Found Shareholding header: "${header.text.trim()}"');
          break;
        }
      }

      dom.Element? shareholdingTable;
      if (sectionHeader != null) {
        // Look in parent section
        var current = sectionHeader.parent;
        while (current != null && shareholdingTable == null) {
          shareholdingTable = current.querySelector('table');
          if (shareholdingTable != null) break;
          current = current.parent;
        }

        // Check next siblings
        if (shareholdingTable == null) {
          var sibling = sectionHeader.nextElementSibling;
          while (sibling != null && shareholdingTable == null) {
            if (sibling.localName == 'table') {
              shareholdingTable = sibling;
              break;
            }
            shareholdingTable = sibling.querySelector('table');
            if (shareholdingTable != null) break;
            sibling = sibling.nextElementSibling;
          }
        }
      }

      if (shareholdingTable != null) {
        final rows = shareholdingTable.querySelectorAll('tr');
        print('👥 Found Shareholding table with ${rows.length} rows');

        // Verify it's the right table
        if (rows.isNotEmpty) {
          final firstCells = rows[0].querySelectorAll('th, td');
          final headerText = firstCells
              .map((c) => c.text.trim().toLowerCase())
              .join(' ');
          
          print('👥 Shareholding table header: "$headerText"');

          // More lenient validation - check if it looks like shareholding data
          if (headerText.isNotEmpty && (headerText.contains('promoter') ||
              headerText.contains('fii') ||
              headerText.contains('dii') ||
              headerText.contains('public') ||
              headerText.contains('mar') ||
              headerText.contains('sep') ||
              headerText.contains('dec') ||
              headerText.contains('jun') ||
              firstCells.length >= 3)) {
            for (final row in rows.skip(1)) {
              // Skip header
              final cells = row.querySelectorAll('td, th');
              if (cells.length >= 2) {
                final category = cells[0].text.trim();
                final values = <String>[];

                for (int i = 1; i < cells.length; i++) {
                  values.add(cells[i].text.trim());
                }

                if (category.isNotEmpty &&
                    !category.toLowerCase().contains('shareholding pattern')) {
                  shareholding[category] = values;
                }
              }
            }
            print('✅ Extracted ${shareholding.length} shareholding categories');
          } else {
            print('⚠️ Table header doesn\'t match Shareholding format');
          }
        }
      } else {
        print('⚠️ Shareholding table not found');
      }
    } catch (e) {
      print('❌ Error extracting shareholding data: $e');
    }

    return shareholding;
  }

  List<Map<String, dynamic>> _extractPeerComparison(dom.Document document) {
    final peers = <Map<String, dynamic>>[];

    try {
      // Find "Peer Comparison" section and get the next table
      final allElements = document.querySelectorAll('*');
      dom.Element? peerTable;

      for (int i = 0; i < allElements.length; i++) {
        final element = allElements[i];
        if (element.text.contains('Peer') &&
            element.text.contains('Comparison')) {
          for (int j = i + 1; j < allElements.length; j++) {
            if (allElements[j].localName == 'table') {
              peerTable = allElements[j];
              break;
            }
          }
          break;
        }
      }

      if (peerTable != null) {
        final rows = peerTable.querySelectorAll('tr');

        // Skip header row
        for (int i = 1; i < rows.length; i++) {
          final cells = rows[i].querySelectorAll('td, th');
          if (cells.length >= 3) {
            final peer = {
              'name': cells[0].text.trim(),
              'cmp': cells.length > 1 ? cells[1].text.trim() : '',
              'pe': cells.length > 2 ? cells[2].text.trim() : '',
              'market_cap': cells.length > 3 ? cells[3].text.trim() : '',
              'div_yield': cells.length > 4 ? cells[4].text.trim() : '',
              'net_profit_qtr': cells.length > 5 ? cells[5].text.trim() : '',
              'qtr_profit_var': cells.length > 6 ? cells[6].text.trim() : '',
              'sales_qtr': cells.length > 7 ? cells[7].text.trim() : '',
              'qtr_sales_var': cells.length > 8 ? cells[8].text.trim() : '',
              'roce': cells.length > 9 ? cells[9].text.trim() : '',
            };
            peers.add(peer);
          }
        }
        print('Extracted ${peers.length} peer companies');
      }
    } catch (e) {
      print('Error extracting peer comparison: $e');
    }

    return peers;
  }
}
