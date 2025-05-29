Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY'],
  webhook_secret: ENV['STRIPE_WEBHOOK_SECRET']
}

# Vérifier que les clés sont définies
if Rails.env.production?
  %w[publishable_key secret_key webhook_secret].each do |key|
    if Rails.configuration.stripe[key.to_sym].blank?
      raise "La clé Stripe #{key} n'est pas définie. Veuillez configurer vos variables d'environnement."
    end
  end
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]