class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:new, :create, :index]
  before_action :check_not_admin, only: [:new, :create]
  before_action :check_not_attendee, only: [:new, :create]
  before_action :check_admin, only: [:index]

  def new
    @attendance = Attendance.new
    @stripe_amount = @event.price * 100 # Stripe utilise les centimes
  end

  def create
    # Si l'événement est gratuit, créer directement la participation
    if @event.price == 0
      @attendance = current_user.attendances.build(event: @event)
      
      if @attendance.save
        redirect_to @event, notice: "Vous êtes inscrit à cet événement!"
      else
        render :new, status: :unprocessable_entity
      end
      return
    end
    
    # Pour les événements payants en environnement de développement, simuler un paiement réussi
    if Rails.env.development? && params[:simulate_payment]
      # Générer un faux ID de paiement pour les tests
      fake_payment_id = "test_payment_#{Time.now.to_i}"
      
      # Créer la participation avec le faux ID de paiement
      @attendance = current_user.attendances.build(
        event: @event,
        stripe_payment_id: fake_payment_id
      )
      
      if @attendance.save
        redirect_to @event, notice: "Paiement simulé réussi! Vous êtes inscrit à cet événement."
      else
        flash.now[:alert] = "Erreur lors de l'inscription: #{@attendance.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
      return
    end
    
    # Pour les événements payants, utiliser Stripe Checkout
    begin
      # Construire les URLs avec le protocole HTTP explicite
      success_url = "http://#{request.host_with_port}#{event_path(@event)}?payment_success=true"
      cancel_url = "http://#{request.host_with_port}#{new_event_attendance_path(@event)}"
      
      # Créer une session Stripe Checkout
      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        customer_email: current_user.email,
        line_items: [{
          price_data: {
            currency: 'eur',
            product_data: {
              name: @event.title,
              description: "Participation à l'événement: #{@event.title}",
            },
            unit_amount: @event.price * 100, # en centimes
          },
          quantity: 1,
        }],
        metadata: {
          user_id: current_user.id,
          event_id: @event.id
        },
        mode: 'payment',
        success_url: success_url,
        cancel_url: cancel_url,
      })
      
      # Rediriger vers la page de paiement Stripe Checkout
      redirect_to session.url, allow_other_host: true
      
    rescue Stripe::StripeError => e
      flash.now[:alert] = "Erreur de paiement: #{e.message}"
      render :new, status: :unprocessable_entity
    rescue => e
      flash.now[:alert] = "Une erreur est survenue: #{e.message}"
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @attendances = @event.attendances.includes(:user)
  end
  
  private
  
  def set_event
    @event = Event.find(params[:event_id])
  end
  
  def check_not_admin
    if current_user == @event.user
      redirect_to @event, alert: "Vous ne pouvez pas vous inscrire à votre propre événement."
    end
  end
  
  def check_not_attendee
    if @event.attendees.include?(current_user)
      redirect_to @event, alert: "Vous êtes déjà inscrit à cet événement."
    end
  end
  
  def check_admin
    unless current_user == @event.user
      redirect_to @event, alert: "Vous n'êtes pas autorisé à accéder à cette page."
    end
  end
  
  def find_or_create_stripe_customer
    if current_user.stripe_customer_id.present?
      # Récupérer le client existant
      Stripe::Customer.retrieve(current_user.stripe_customer_id)
    else
      # Créer un nouveau client
      customer = Stripe::Customer.create({
        email: current_user.email,
        name: "#{current_user.first_name} #{current_user.last_name}"
      })
      
      # Sauvegarder l'ID du client dans la base de données
      current_user.update(stripe_customer_id: customer.id)
      customer
    end
  end
end
