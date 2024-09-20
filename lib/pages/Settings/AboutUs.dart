import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Pages/Settings/GenericSettingsPage.dart';

class AboutUsPage extends StatefulWidget {
  @override
  final Key? key;

  AboutUsPage({this.key}) : super(key: key);
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
   // final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '1.0.0'; //packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GenericSettingsPage(
      title: 'About Us',
      child: ListView(
        children: [
          ListTile(
            title: Text('Version', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: Text(_appVersion, style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          ListTile(
            title:
                Text('Privacy Policy', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to privacy policy page
              context.pushNamed('settings/abousUs/privacyPolicy');
            },
          ),
          ListTile(
            title:
                Text('Terms of Service', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to terms of service page
              context.pushNamed('settings/abousUs/termsOfService');
            },
          ),
          ListTile(
            title: Text('Contact', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to terms of service page
              context.pushNamed('settings/aboutUs/contact');
            },
          ),
        ],
      ),
    );
  }
}

// Placeholder pages for Privacy Policy and Terms of Service
class PrivacyPolicyPage extends StatelessWidget {
  @override
  final Key? key;

  PrivacyPolicyPage({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericSettingsPage(
      title: "Privacy Policy",
      child: Center(
        child: Text('Privacy Policy content goes here.'),
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  @override
  final Key? key;

  TermsOfServicePage({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericSettingsPage(
      title: "Terms of Service",
      child: Center(
        child: Text('Terms of Service content goes here.'),
      ),
    );
  }
}

class ContactUsPage extends StatelessWidget {
  @override
  final Key? key;

  ContactUsPage({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericSettingsPage(
      title: 'Contact Us',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'If you have any questions, feel free to reach out to us at:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Email: support@example.com',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: +1 234 567 890',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            SizedBox(height: 8),
            Text(
              'Address: 123 Main Street, City, Country',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
