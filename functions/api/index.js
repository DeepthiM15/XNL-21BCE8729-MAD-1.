/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const cors = require("cors")({ origin: true });

module.exports = async (req, res) => {
    cors(req, res, async () => {
        try {
            const { email, amount } = req.body;
            let customerId;

            // Find or create a customer
            const customerList = await stripe.customers.list({ email, limit: 1 });
            if (customerList.data.length > 0) {
                customerId = customerList.data[0].id;
            } else {
                const customer = await stripe.customers.create({ email });
                customerId = customer.id;
            }

            // Create ephemeral key
            const ephemeralKey = await stripe.ephemeralKeys.create(
                { customer: customerId },
                { apiVersion: '2023-10-16' }
            );

            // Create payment intent
            const paymentIntent = await stripe.paymentIntents.create({
                amount: parseInt(amount),
                currency: 'usd',
                customer: customerId,
            });

            res.status(200).json({
                paymentIntent: paymentIntent.client_secret,
                ephemeralKey: ephemeralKey.secret,
                customer: customerId,
                success: true,
            });
        } catch (error) {
            res.status(500).json({ success: false, error: error.message });
        }
    });
};
