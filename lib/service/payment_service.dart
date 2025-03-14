import 'dart:convert';
import 'dart:developer';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PaymentService {
  PaymentService() {
    // Securely store Stripe keys
    Stripe.publishableKey = "pk_test_51R2bcjQ8pIsRNhzFBKxF4xmT92QuZzJcZPxTu8LOhsK5DCnrrXnJ3fXgUtQhBuR3wwrOuf1uoFA6bNratXc42c0G00wXVWBKMF";
    Stripe.instance.applySettings();
  }

  Future<void> initPaymentSheet(BuildContext context, {required String email, required int amount}) async {
    try {
      final response = await http.post(
        Uri.parse('https://bank-4nxhapqmx-deepthis-projects-b86b6b62.vercel.app/api/stripePaymentIntentRequest'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'amount': amount,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch payment intent: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      log('Payment Intent Response: $jsonResponse');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['paymentIntent'],
          merchantDisplayName: 'Flutter Stripe Store Demo',
          customerId: jsonResponse['customer'],
          customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Payment completed successfully!')),
      );
    } catch (e) {
      log('Payment Error: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: $e')),
      );
    }
  }
}
