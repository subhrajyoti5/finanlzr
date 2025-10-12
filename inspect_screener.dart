import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

void main() async {
  try {
    final response = await http.get(
      Uri.parse('https://www.screener.in/company/RELIANCE/consolidated/'),
    );

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);

      print('=== Looking for price elements ===');

      // Look for elements containing price-like text
      final allElements = document.querySelectorAll('*');
      print('Total elements: ${allElements.length}');

      // Look for elements with specific classes or IDs
      final priceElements = document.querySelectorAll(
        '[class*="price"], [id*="price"]',
      );
      print('Price-related elements: ${priceElements.length}');
      for (final element in priceElements.take(5)) {
        print(
          '  ${element.localName}.${element.className}: ${element.text.trim()}',
        );
      }

      // Look for elements containing ₹ symbol
      final rupeeElements = document
          .querySelectorAll('*')
          .where((element) => element.text.contains('₹'))
          .toList();
      print('Elements with ₹ symbol: ${rupeeElements.length}');
      for (final element in rupeeElements.take(10)) {
        print(
          '  ${element.localName}.${element.className}: ${element.text.trim()}',
        );
      }

      // Look for table data that might contain financial info
      final tables = document.querySelectorAll('table');
      print('Tables found: ${tables.length}');

      for (int i = 0; i < tables.length && i < 3; i++) {
        final table = tables[i];
        print('Table ${i + 1} rows: ${table.querySelectorAll('tr').length}');

        final headers = table.querySelectorAll('th');
        if (headers.isNotEmpty) {
          print('  Headers: ${headers.map((h) => h.text.trim()).join(', ')}');
        }

        final firstRow = table.querySelectorAll('tr').skip(1).firstOrNull;
        if (firstRow != null) {
          final cells = firstRow.querySelectorAll('td');
          if (cells.isNotEmpty) {
            print(
              '  First data row: ${cells.map((c) => c.text.trim()).join(', ')}',
            );
          }
        }
      }

      // Look for specific financial metrics
      final spans = document.querySelectorAll('span');
      final metricSpans = spans
          .where(
            (span) =>
                span.text.contains('P/E') ||
                span.text.contains('ROE') ||
                span.text.contains('Market') ||
                span.text.contains('Capital'),
          )
          .toList();

      print('Spans with financial metrics: ${metricSpans.length}');
      for (final span in metricSpans.take(5)) {
        print('  ${span.text.trim()}');
      }
    } else {
      print('Failed to fetch page. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
