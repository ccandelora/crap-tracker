import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              _buildThemeSelector(context, themeProvider),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Privacy',
            children: [
              SwitchListTile(
                title: const Text('Save Data Locally Only'),
                subtitle: const Text('Your data is never uploaded to the cloud'),
                value: true, // Always true as we only support local storage for now
                onChanged: null, // Disabled as this is not changeable
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Dice Roll Settings',
            children: [
              SwitchListTile(
                title: const Text('Animations'),
                subtitle: const Text('Show dice roll animations'),
                value: true, 
                onChanged: (value) {
                  // Implement animation toggle functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This feature will be available in a future update.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Play dice rolling sounds'),
                value: false,
                onChanged: (value) {
                  // Implement sound toggle functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This feature will be available in a future update.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.info_outline),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Licenses'),
                subtitle: const Text('View open-source licenses'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'The Rail',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Light Theme'),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (_) => themeProvider.setLightMode(),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark Theme'),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (_) => themeProvider.setDarkMode(),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System Theme'),
          subtitle: const Text('Follow system settings'),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (_) => themeProvider.setSystemMode(),
        ),
      ],
    );
  }
} 