import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  Future<void> sendReminder({
    required String phone,
    required String customerName,
    required int remainingBalance,
  }) async {
    String phoneNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (phoneNumber.startsWith('0')) {
      phoneNumber = '92${phoneNumber.substring(1)}';
    } else if (!phoneNumber.startsWith('92')) {
      phoneNumber = '92$phoneNumber';
    }
    final message =
        '''
Assalam-o-Alaikum $customerName,

Your remaining balance is Rs. $remainingBalance.

Please clear your payment when possible.

Thank you.
''';

    final url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
