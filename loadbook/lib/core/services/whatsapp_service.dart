import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  Future<void> sendReminder({
    required String phone,
    required String customerName,
    required int balance,
  }) async {
    final message =
        'Assalam-o-Alaikum $customerName,\n\n'
        'Your remaining balance is Rs. $balance.\n'
        'Kindly clear your payment.\n\n'
        'Thank you.';

    final phoneNumber = phone.replaceAll('+', '');

    final uri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
