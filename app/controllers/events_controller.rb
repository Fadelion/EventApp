class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :check_event_admin, only: [:edit, :update, :destroy]

  def index
    @events = Event.all.order(start_date: :asc)
  end

  def show
    # Vérifier si l'utilisateur vient de payer avec succès
    if params[:payment_success] && current_user
      flash.now[:notice] = "Paiement réussi! Votre inscription sera confirmée dès que nous recevrons la confirmation de Stripe."
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)

    if @event.save
      redirect_to @event, notice: 'Événement créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Événement mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Événement supprimé avec succès.'
  end

  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def check_event_admin
    unless current_user == @event.user
      redirect_to events_path, alert: "Vous n'êtes pas autorisé à modifier cet événement."
    end
  end
  
  def event_params
    params.require(:event).permit(:title, :description, :start_date, :duration, :price, :location)
  end
end