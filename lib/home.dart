

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home"),
//         centerTitle: true,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:bank_app/service/payment_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PaymentService _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stripe Payment"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () async {
            await _paymentService.initPaymentSheet(
              context,
              email: "example@gmail.com",
              amount: 200000,
            );
          },
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}
