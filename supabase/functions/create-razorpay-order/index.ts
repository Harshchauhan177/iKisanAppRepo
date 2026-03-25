// Supabase Edge Function: create-razorpay-order
// Creates a Razorpay order with Auth Hold (Manual Capture) enabled
// This prevents the payment from being automatically captured, allowing for review/cancellation

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

// CORS headers for cross-origin requests from iOS app
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface CreateOrderRequest {
  amount: number; // Amount in INR (will be converted to paise)
  currency?: string;
  receipt?: string;
  notes?: Record<string, string>;
}

interface RazorpayOrderResponse {
  id: string;
  entity: string;
  amount: number;
  amount_paid: number;
  amount_due: number;
  currency: string;
  receipt: string;
  status: string;
  attempts: number;
  notes: Record<string, string>;
  created_at: number;
}

serve(async (req: Request) => {
  // Handle CORS preflight request
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Get Razorpay credentials from environment variables
    const RAZORPAY_KEY_ID = Deno.env.get("RAZORPAY_KEY_ID");
    const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET");

    if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) {
      console.error("Missing Razorpay credentials in environment variables");
      return new Response(
        JSON.stringify({
          success: false,
          error: "Server configuration error: Missing payment credentials",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse request body
    const requestBody: CreateOrderRequest = await req.json();
    const { amount, currency = "INR", receipt, notes = {} } = requestBody;

    // Validate amount
    if (!amount || amount <= 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Invalid amount: Amount must be greater than 0",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Convert amount from INR to paise (smallest currency unit)
    const amountInPaise = Math.round(amount * 100);

    // Prepare Razorpay order payload
    // CRITICAL: payment_capture: 0 enables Auth Hold (Manual Capture)
    // This holds the amount on customer's card but doesn't capture it automatically
    // The payment must be explicitly captured later via Razorpay API
    const orderPayload = {
      amount: amountInPaise,
      currency: currency,
      receipt: receipt || `receipt_${Date.now()}`,
      payment_capture: 0, // AUTH HOLD: Do NOT auto-capture payment
      notes: {
        ...notes,
        source: "ikisan_coequip",
        created_via: "supabase_edge_function",
      },
    };

    console.log("Creating Razorpay order with payload:", JSON.stringify(orderPayload));

    // Create Base64 encoded auth string for Razorpay API
    const authString = btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`);

    // Call Razorpay Orders API
    const razorpayResponse = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${authString}`,
      },
      body: JSON.stringify(orderPayload),
    });

    // Parse Razorpay response
    const razorpayData = await razorpayResponse.json();

    if (!razorpayResponse.ok) {
      console.error("Razorpay API error:", JSON.stringify(razorpayData));
      return new Response(
        JSON.stringify({
          success: false,
          error: razorpayData.error?.description || "Failed to create order",
          razorpay_error: razorpayData.error,
        }),
        {
          status: razorpayResponse.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const order: RazorpayOrderResponse = razorpayData;

    console.log("Razorpay order created successfully:", order.id);

    // Return the order details to the client
    // The client needs the order_id to initialize the Razorpay checkout
    return new Response(
      JSON.stringify({
        success: true,
        order_id: order.id,
        amount: order.amount, // Amount in paise
        amount_inr: order.amount / 100, // Amount in INR for display
        currency: order.currency,
        receipt: order.receipt,
        status: order.status,
        notes: order.notes,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Internal server error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
