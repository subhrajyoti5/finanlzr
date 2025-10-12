import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanlzr/features/results/providers/analysis_provider.dart';
import 'package:finanlzr/features/results/models/analysis_data.dart';

class DetailedInsightsScreen extends ConsumerStatefulWidget {
  final String ticker;

  const DetailedInsightsScreen({super.key, required this.ticker});

  @override
  ConsumerState<DetailedInsightsScreen> createState() =>
      _DetailedInsightsScreenState();
}

class _DetailedInsightsScreenState
    extends ConsumerState<DetailedInsightsScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger data fetching when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 DetailedInsightsScreen opened for ticker: ${widget.ticker}');
      ref.read(analysisProvider.notifier).fetchAnalysis(widget.ticker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.ticker} - Detailed Insights'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: analysisState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : analysisState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${analysisState.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(analysisProvider.notifier)
                        .fetchAnalysis(widget.ticker),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : analysisState.data != null
          ? _buildInsightsContent(context, analysisState.data!)
          : const Center(child: Text('No data available')),
    );
  }

  Widget _buildInsightsContent(BuildContext context, AnalysisData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Overview - Always expanded
          if (data.companyOverview != null) ...[
            _buildCompanyOverview(data.companyOverview!),
            const SizedBox(height: 16),
          ],

          // Key Metrics - Always expanded
          if (data.keyMetrics != null) ...[
            _buildKeyMetrics(context, data.keyMetrics!),
            const SizedBox(height: 16),
          ],

          // Quarterly Results - Expandable
          if (data.quarterlyResults != null &&
              data.quarterlyResults!.isNotEmpty)
            _buildExpandableSection(
              title: 'Quarterly Results',
              icon: Icons.bar_chart,
              count: data.quarterlyResults!.length,
              child: _buildQuarterlyResults(data.quarterlyResults!),
            ),

          // Profit & Loss - Expandable
          if (data.profitLoss != null && data.profitLoss!.isNotEmpty)
            _buildExpandableSection(
              title: 'Profit & Loss Statement',
              icon: Icons.trending_up,
              count: data.profitLoss!.length,
              child: _buildFinancialTable(data.profitLoss!),
            ),

          // Balance Sheet - Expandable
          if (data.balanceSheet != null && data.balanceSheet!.isNotEmpty)
            _buildExpandableSection(
              title: 'Balance Sheet',
              icon: Icons.account_balance,
              count: data.balanceSheet!.length,
              child: _buildFinancialTable(data.balanceSheet!),
            ),

          // Cash Flow - Expandable
          if (data.cashFlow != null && data.cashFlow!.isNotEmpty)
            _buildExpandableSection(
              title: 'Cash Flow Statement',
              icon: Icons.water_drop,
              count: data.cashFlow!.length,
              child: _buildFinancialTable(data.cashFlow!),
            ),

          // Ratios - Expandable
          if (data.ratios != null && data.ratios!.isNotEmpty)
            _buildExpandableSection(
              title: 'Financial Ratios',
              icon: Icons.percent,
              count: data.ratios!.length,
              child: _buildFinancialTable(data.ratios!),
            ),

          // Shareholding Pattern - Expandable
          if (data.shareholding != null && data.shareholding!.isNotEmpty)
            _buildExpandableSection(
              title: 'Shareholding Pattern',
              icon: Icons.pie_chart,
              count: data.shareholding!.length,
              child: _buildShareholdingPattern(data.shareholding!),
            ),

          // Peer Comparison - Expandable
          if (data.peers != null && data.peers!.isNotEmpty)
            _buildExpandableSection(
              title: 'Peer Comparison',
              icon: Icons.compare,
              count: data.peers!.length,
              child: _buildPeerComparison(data.peers!),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required int count,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            '$count items',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          children: [Padding(padding: const EdgeInsets.all(12), child: child)],
        ),
      ),
    );
  }

  Widget _buildCompanyOverview(Map<String, dynamic> overview) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.business, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Company Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Company Name
            if (overview['name'] != null) ...[
              Text(
                overview['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Price and Market Cap in a row
            Row(
              children: [
                if (overview['price'] != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${overview['price']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (overview['price'] != null && overview['marketCap'] != null)
                  const SizedBox(width: 12),
                if (overview['marketCap'] != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Market Cap',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${overview['marketCap']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // About section in expandable
            if (overview['about'] != null &&
                overview['about'].toString().trim().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  title: const Text(
                    'About Company',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        _cleanAboutText(overview['about']),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),

            // Key Points in expandable
            if (overview['keyPoints'] != null &&
                (overview['keyPoints'] as List).isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(
                    Icons.stars,
                    color: Colors.green[700],
                    size: 20,
                  ),
                  title: const Text(
                    'Key Highlights',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        children: _buildKeyHighlights(overview['keyPoints']),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, Map<String, dynamic> metrics) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Key Financial Metrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: metrics.entries.map((entry) {
                return Container(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.blue[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key
                            .replaceAll('_', ' ')
                            .split(' ')
                            .map(
                              (word) =>
                                  word[0].toUpperCase() + word.substring(1),
                            )
                            .join(' '),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuarterlyResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) return const SizedBox.shrink();

    final headers = [
      'Quarter',
      'Sales',
      'Expenses',
      'OP Profit',
      'OPM %',
      'Other Income',
      'Interest',
      'Depreciation',
      'PBT',
      'Tax %',
      'Net Profit',
      'EPS',
    ];

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: headers
              .map(
                (header) => DataColumn(
                  label: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
          rows: results
              .map(
                (result) => DataRow(
                  cells: [
                    DataCell(Text(result['quarter'] ?? '')),
                    DataCell(Text(result['sales'] ?? '')),
                    DataCell(Text(result['expenses'] ?? '')),
                    DataCell(Text(result['operating_profit'] ?? '')),
                    DataCell(Text(result['opm_percent'] ?? '')),
                    DataCell(Text(result['other_income'] ?? '')),
                    DataCell(Text(result['interest'] ?? '')),
                    DataCell(Text(result['depreciation'] ?? '')),
                    DataCell(Text(result['profit_before_tax'] ?? '')),
                    DataCell(Text(result['tax_percent'] ?? '')),
                    DataCell(Text(result['net_profit'] ?? '')),
                    DataCell(Text(result['eps'] ?? '')),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFinancialTable(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    // Get the first entry's value to determine columns
    final firstEntry = data.entries.first;
    final years = firstEntry.value is List ? (firstEntry.value as List) : [];

    if (years.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(
              label: Text(
                'Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...years.map(
              (year) => DataColumn(
                label: Text(
                  year.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: data.entries
              .map(
                (entry) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...(entry.value is List ? (entry.value as List) : []).map(
                      (value) => DataCell(Text(value.toString())),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildShareholdingPattern(Map<String, dynamic> shareholding) {
    if (shareholding.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    // Get the first entry's value to determine columns
    final firstEntry = shareholding.entries.first;
    final quarters = firstEntry.value is List ? (firstEntry.value as List) : [];

    if (quarters.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(
              label: Text(
                'Shareholder',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...quarters.map(
              (quarter) => DataColumn(
                label: Text(
                  quarter.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: shareholding.entries
              .map(
                (entry) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...(entry.value is List ? (entry.value as List) : []).map(
                      (value) => DataCell(Text(value.toString())),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPeerComparison(List<Map<String, dynamic>> peers) {
    final headers = [
      'Name',
      'CMP',
      'P/E',
      'Market Cap',
      'Div Yield',
      'Net Profit Qtr',
      'Qtr Profit Var',
      'Sales Qtr',
      'Qtr Sales Var',
      'ROCE',
    ];

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: headers
              .map(
                (header) => DataColumn(
                  label: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
          rows: peers
              .map(
                (peer) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        peer['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(peer['cmp'] ?? '')),
                    DataCell(Text(peer['pe'] ?? '')),
                    DataCell(Text(peer['market_cap'] ?? '')),
                    DataCell(Text(peer['div_yield'] ?? '')),
                    DataCell(Text(peer['net_profit_qtr'] ?? '')),
                    DataCell(Text(peer['qtr_profit_var'] ?? '')),
                    DataCell(Text(peer['sales_qtr'] ?? '')),
                    DataCell(Text(peer['qtr_sales_var'] ?? '')),
                    DataCell(Text(peer['roce'] ?? '')),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // Helper method to clean about text
  String _cleanAboutText(String text) {
    // Remove extra whitespace and newlines
    String cleaned = text.trim();

    // Remove "About" header if present
    cleaned = cleaned.replaceFirst(
      RegExp(r'^About\s*', caseSensitive: false),
      '',
    );

    // Remove "Key Points" section and everything after it
    final keyPointsIndex = cleaned.toLowerCase().indexOf('key points');
    if (keyPointsIndex != -1) {
      cleaned = cleaned.substring(0, keyPointsIndex);
    }

    // Remove "Read More" text
    cleaned = cleaned.replaceAll(
      RegExp(r'Read More', caseSensitive: false),
      '',
    );

    // Remove "Website" text
    cleaned = cleaned.replaceAll(RegExp(r'Website', caseSensitive: false), '');

    // Collapse multiple newlines into single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  // Helper method to build formatted key highlights
  List<Widget> _buildKeyHighlights(List<dynamic> keyPoints) {
    final List<Widget> widgets = [];

    // Separate Pros and Cons
    final List<String> pros = [];
    final List<String> cons = [];

    for (final point in keyPoints) {
      final text = point.toString().trim();
      if (text.isEmpty ||
          text.toLowerCase() == 'pros' ||
          text.toLowerCase() == 'cons')
        continue;

      // Check if this is a positive or negative point
      if (text.toLowerCase().contains('company has') ||
          text.toLowerCase().contains('good') ||
          text.toLowerCase().contains('strong') ||
          text.toLowerCase().contains('healthy') ||
          text.toLowerCase().contains('consistent') ||
          !text.toLowerCase().contains('poor') &&
              !text.toLowerCase().contains('high debt') &&
              !text.toLowerCase().contains('trading at')) {
        pros.add(text);
      } else {
        cons.add(text);
      }
    }

    // Add Pros section
    if (pros.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.thumb_up, size: 18, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Strengths',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      );

      for (final pro in pros) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pro,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (cons.isNotEmpty) widgets.add(const SizedBox(height: 8));
    }

    // Add Cons section
    if (cons.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.warning_amber, size: 18, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Areas of Concern',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
      );

      for (final con in cons) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange[600],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    con,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
