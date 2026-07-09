import 'package:flutter/material.dart';
import 'package:mobile/features/community/models/cost_split_item.dart';
import 'package:mobile/features/community/services/order_service.dart';

class CostSplitScreen extends StatefulWidget {
  final String orderId;
  final String orderTitle;

  const CostSplitScreen({
    super.key,
    required this.orderId,
    required this.orderTitle,
  });

  @override
  State<CostSplitScreen> createState() => _CostSplitScreenState();
}

class _CostSplitScreenState extends State<CostSplitScreen> {
  static const _bg = Color(0xFFF8FAFC);
  static const _card = Colors.white;
  static const _border = Color(0xFFF1F5F9);
  static const _muted = Color(0xFF94A3B8);
  static const _textPrimary = Color(0xFF1E1B4B);
  static const _accent = Color(0xFF7C3AED);
  static const _cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2)),
  ];

  bool _loading = true;
  String? _error;
  List<CostSplitItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await OrderService.getCostSplit(widget.orderId);
      final items = raw.map((e) => CostSplitItem.fromJson(e)).toList();
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _sgd(double v) => 'S\$${v.toStringAsFixed(2)}';

  String _formatLocal(double v) {
    final rounded = v.round();
    return rounded.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String? _localLine(CostSplitItem item) {
    if (item.currency == 'SGD') return null;
    return '≈ ${_formatLocal(item.totalLocal)} ${item.currency}';
  }

  double get _totalSgd => _items.fold(0, (sum, i) => sum + i.totalSgd);

  double get _totalLocal => _items.fold(0, (sum, i) => sum + i.totalLocal);

  String get _viewerCurrency => _items.isNotEmpty ? _items.first.currency : 'SGD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textPrimary,
        title: Text(widget.orderTitle,
            style: const TextStyle(fontFamily: 'Jost', fontSize: 16)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _accent,
        backgroundColor: _card,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.error_outline, color: _muted, size: 40),
          const SizedBox(height: 12),
          Center(
            child: Text(_error!,
                style: const TextStyle(color: _muted, fontFamily: 'Jost'),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _load,
              child: const Text('Retry', style: TextStyle(color: _accent)),
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text('No participants yet',
                style: TextStyle(color: _muted, fontFamily: 'Jost')),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 20),
        const Text(
          'Split by participant',
          style: TextStyle(
            color: _textPrimary,
            fontFamily: 'Jost',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ..._items.map(_buildParticipantRow),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final showLocal = _viewerCurrency != 'SGD';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total order cost',
              style: TextStyle(color: _muted, fontFamily: 'Jost', fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            _sgd(_totalSgd),
            style: const TextStyle(
              color: _textPrimary,
              fontFamily: 'Jost',
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showLocal) ...[
            const SizedBox(height: 2),
            Text('≈ ${_formatLocal(_totalLocal)} $_viewerCurrency',
                style: const TextStyle(color: _muted, fontFamily: 'Jost', fontSize: 13)),
          ],
          const SizedBox(height: 10),
          Text('${_items.length} participants',
              style: const TextStyle(color: _muted, fontFamily: 'Jost', fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(CostSplitItem item) {
    final localLine = _localLine(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _accent.withValues(alpha: 0.18),
            child: Text(
              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: _accent, fontFamily: 'Jost', fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontFamily: 'Jost',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Host',
                            style: TextStyle(
                                color: Color(0xFFF59E0B), fontSize: 10, fontFamily: 'Jost')),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Items ${_sgd(item.itemCostSgd)} · Ship ${_sgd(item.shippingSplitSgd)}',
                  style: const TextStyle(color: _muted, fontFamily: 'Jost', fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _sgd(item.totalSgd),
                style: const TextStyle(
                  color: _textPrimary,
                  fontFamily: 'Jost',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (localLine != null)
                Text(localLine, style: const TextStyle(color: _muted, fontFamily: 'Jost', fontSize: 10)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (item.paid ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.paid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    color: item.paid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    fontSize: 10,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}