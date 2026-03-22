import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: const Text('Dark mode'),
              subtitle: const Text(
                'Switch between the current light and dark app themes.',
              ),
              value: isDarkMode,
              onChanged: onDarkModeChanged,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Storage',
            items: [
              'Canonical storage: local database in V1',
              'Markdown export/import support',
              'Optional filesystem mirroring later',
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Sync Roadmap',
            items: [
              'No cloud sync in alpha',
              'Provider abstraction planned for Supabase, Firebase, and custom backends',
              'Local-first remains the source of truth',
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Release Focus',
            items: [
              'Reliable CRUD for notes and todos',
              'Search, tags, archive, and export',
              'Android-first UX polish before provider work',
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
