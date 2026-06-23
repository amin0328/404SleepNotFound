import 'package:flutter/material.dart';
import 'package:mobile/core/services/currency_service.dart';
import 'package:mobile/core/utils/country_data.dart';
import '../services/order_service.dart';

class JoinOrderSheet extends StatefulWidget {
  final String orderId;
  final String orderTitle;
  final String originCountry;

  const JoinOrderSheet({
    super.key,
    required this.orderId,
    required this.orderTitle,
    required this.originCountry,
  });

  @override
  State<JoinOrderSheet> createState() => _JoinOrderSheetState();
}

class _OrderItemEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    qtyController.dispose();
  }

  double get lineTotalLocal {
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final qty = int.tryParse(qtyController.text.trim()) ?? 0;
    return price * qty;
  }

  Map<String, dynamic>? toJson(double rate) {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final qty = int.tryParse(qtyController.text.trim());
    if (name.isEmpty || price == null || qty == null || qty <= 0) return null;
    final priceSgd = rate > 0 ? price / rate : price;
    return {
      'name': name,
      'price_sgd': double.parse(priceSgd.toStringAsFixed(2)),
      'qty': qty,
    };
  }
}

class _JoinOrderSheetState extends State<JoinOrderSheet> {
  final List<_OrderItemEntry> _entries = [_OrderItemEntry()];
  bool _isSubmitting = false;

  String _currencyCode = 'SGD';
  double _rate = 1; // origin currency units per 1 SGD
  bool _isLoadingCurrency = true;

  @override
  void initState() {
    super.initState();
    _resolveOriginCurrency();
  }

  Future<void> _resolveOriginCurrency() async {
    try {
      final countries = await loadCountries();
      final currency = currencyForCountryName(countries, widget.originCountry);
      if (currency == null || currency == 'SGD') {
        setState(() {
          _currencyCode = 'SGD';
          _rate = 1;
          _isLoadingCurrency = false;
        });
        return;
      }
      final rate = await CurrencyService.getRate(currency);
      setState(() {
        _currencyCode = currency;
        _rate = (rate == null || rate == 0) ? 1 : rate;
        _isLoadingCurrency = false;
      });
    } catch (_) {
      // Fall back to treating prices as SGD if the country/rate lookup
      // fails for any reason — better to let the user join than to block
      // them on a currency-lookup hiccup.
      setState(() {
        _currencyCode = 'SGD';
        _rate = 1;
        _isLoadingCurrency = false;
      });
    }
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  void _addEntry() => setState(() => _entries.add(_OrderItemEntry()));

  void _removeEntry(int index) {
    setState(() {
      _entries[index].dispose();
      _entries.removeAt(index);
    });
  }

  double get _totalLocal => _entries.fold(0, (sum, e) => sum + e.lineTotalLocal);

  double get _totalSgd => _rate > 0 ? _totalLocal / _rate : _totalLocal;

  Future<void> _handleSubmit() async {
    final items = _entries
        .map((e) => e.toJson(_rate))
        .whereType<Map<String, dynamic>>()
        .toList();

    setState(() => _isSubmitting = true);
    try {
      await OrderService.joinOrder(widget.orderId, items);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF818CF8), width: 1.5),
        ),
      );

  String _formatLocal(double v) {
    final isWholeCurrency = _currencyCode == 'KRW' || _currencyCode == 'JPY' || _currencyCode == 'VND';
    return isWholeCurrency ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Join "${widget.orderTitle}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isLoadingCurrency
                  ? 'Loading prices...'
                  : 'Prices are in $_currencyCode (this order\'s origin currency). You can leave this blank and join with no items for now.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),

            if (_isLoadingCurrency)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else ...[
              ...List.generate(_entries.length, (i) => _buildItemRow(i)),

              GestureDetector(
                onTap: _addEntry,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16, color: Color(0xFF818CF8)),
                      SizedBox(width: 6),
                      Text('Add item',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF818CF8))),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your items total',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        Text('${_formatLocal(_totalLocal)} $_currencyCode',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
                      ],
                    ),
                    if (_currencyCode != 'SGD') ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('≈ S\$${_totalSgd.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF818CF8), Color(0xFFA78BFA)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x3D818CF8), blurRadius: 14, offset: Offset(0, 4)),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                    label: Text(
                      _isSubmitting ? 'Joining...' : 'Join Order',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int index) {
    final entry = _entries[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: entry.nameController,
              decoration: _inputDecoration('Item name'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: entry.priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Price').copyWith(prefixText: '$_currencyCode '),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: entry.qtyController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Qty'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 4),
          if (_entries.length > 1)
            IconButton(
              onPressed: () => _removeEntry(index),
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}