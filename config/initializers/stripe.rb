Stripe.api_key = Recognize::Application.config.credentials["stripe"]["secret_key"] rescue nil
STRIPE_PUBLIC_KEY = Recognize::Application.config.credentials["stripe"]["public_key"] rescue nil
