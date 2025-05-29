# Be sure to restart your server when you modify this file.

# Active la Content Security Policy pour renforcer la sécurité contre XSS et injections.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https
    # Autorise Stripe uniquement sur les pages nécessaires (adapter si besoin)
    policy.frame_src   "https://js.stripe.com", "https://hooks.stripe.com"
    policy.script_src  :self, :https, "https://js.stripe.com"
    # policy.connect_src :self, :https, "wss://*"
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Génère des nonces pour les scripts/styles inline si besoin
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Pour tester la politique sans la bloquer, décommente la ligne suivante :
  # config.content_security_policy_report_only = true
end
