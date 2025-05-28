class UserMailer < ApplicationMailer
 def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Bienvenue sur notre plateforme d\'événements !')
  end 
end
