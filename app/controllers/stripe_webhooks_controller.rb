class StripeWebhooksController < ApplicationController
  # Désactiver la vérification CSRF pour les webhooks Stripe
  # C'est sécurisé car nous vérifions la signature Stripe
  skip_before_action :verify_authenticity_token
  
  # Limiter l'accès aux webhooks
  before_action :verify_webhook_origin
  
  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']
    
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { error: e.message }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: e.message }, status: 400
      return
    end
    
    # Gérer les événements spécifiques
    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      handle_checkout_session_completed(session)
    end
    
    render json: { received: true }
  end
  
  private
  
  def verify_webhook_origin
    # Vérifier que la requête provient bien de Stripe
    # Cette vérification est redondante avec la vérification de signature,
    # mais ajoute une couche de sécurité supplémentaire
    unless request.user_agent&.include?('Stripe') || Rails.env.development?
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return false
    end
  end
  
  def handle_checkout_session_completed(session)
    # Récupérer les métadonnées de la session
    user_id = session.metadata.user_id
    event_id = session.metadata.event_id
    
    # Vérifier que les métadonnées sont présentes
    if user_id.blank? || event_id.blank?
      Rails.logger.error("Webhook error: missing metadata in session #{session.id}")
      return
    end
    
    begin
      # Créer l'inscription à l'événement
      user = User.find(user_id)
      event = Event.find(event_id)
      
      # Vérifier si l'utilisateur n'est pas déjà inscrit
      unless user.attended_events.include?(event)
        attendance = Attendance.create(
          user: user,
          event: event,
          stripe_payment_id: session.payment_intent
        )
        
        # Mettre à jour l'ID client Stripe si nécessaire
        if user.stripe_customer_id.blank? && session.customer.present?
          user.update(stripe_customer_id: session.customer)
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("Webhook error: #{e.message} for session #{session.id}")
    end
  end
end