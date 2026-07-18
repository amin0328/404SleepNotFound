import 'package:flutter/material.dart';

class HousingResourceItem {
  final String label;
  final String description;
  final String url;
  final IconData icon;
  final bool isOfficial;

  const HousingResourceItem({
    required this.label,
    required this.description,
    required this.url,
    required this.icon,
    this.isOfficial = false,
  });
}

class HousingResourcesSection extends StatelessWidget {
  final String region;
  final List<HousingResourceItem> resources;
  final ValueChanged<HousingResourceItem> onOpen;

  const HousingResourcesSection({
    super.key,
    required this.region,
    required this.resources,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final titleRegion = region == 'All' ? 'Singapore' : region;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Housing resources for $titleRegion',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B), fontFamily: 'Jost')),
          const SizedBox(height: 4),
          const Text('Official guidance and external live-listing searches.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Jost')),
          const SizedBox(height: 12),
          ...resources.map((resource) => _ResourceTile(resource: resource, onTap: () => onOpen(resource))),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final HousingResourceItem resource;
  final VoidCallback onTap;

  const _ResourceTile({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(resource.icon, color: const Color(0xFF7C3AED), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text(resource.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B), fontFamily: 'Jost'))),
                      if (resource.isOfficial) const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text('OFFICIAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(resource.description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'Jost')),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, size: 16, color: Color(0xFF7C3AED)),
            ],
          ),
        ),
      ),
    );
  }
}
