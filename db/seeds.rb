# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Création des seeds..."

# Nettoyage de la base de données
puts "Nettoyage de la base de données..."
Attendance.destroy_all
Event.destroy_all
User.destroy_all

puts "Création des utilisateurs..."

# Création des utilisateurs
users = []
10.times do |i|
  user = User.create!(
    email: "user#{i+1}@yopmail.com",
    encrypted_password: "password123",
    first_name: ["Jean", "Marie", "Pierre", "Sophie", "Paul", "Julie", "Michel", "Claire", "Thomas", "Emma"][i],
    last_name: ["Dupont", "Martin", "Bernard", "Dubois", "Moreau", "Laurent", "Simon", "Michel", "Lefebvre", "Leroy"][i],
    description: "Je suis un utilisateur passionné d'événements et j'adore découvrir de nouvelles expériences !"
  )
  users << user
  puts "✅ Utilisateur créé : #{user.first_name} #{user.last_name} (#{user.email})"
end

puts "Création des événements..."

# Création des événements
events = []
15.times do |i|
  event = Event.create!(
    title: [
      "Conférence Tech 2024",
      "Atelier Cuisine Italienne",
      "Concert Jazz en plein air",
      "Formation Ruby on Rails",
      "Exposition d'Art Moderne",
      "Tournoi de Tennis",
      "Soirée Networking Startup",
      "Cours de Yoga matinal",
      "Dégustation de Vins",
      "Marathon de Paris",
      "Workshop Photographie",
      "Spectacle de Théâtre",
      "Conférence Marketing Digital",
      "Festival de Musique Électro",
      "Cours de Cuisine Végane"
    ][i],
    description: "Ceci est une description détaillée de l'événement qui fait plus de 20 caractères et explique le contenu, les objectifs et les bénéfices que les participants peuvent attendre de cet événement unique.",
    start_date: rand(1..30).days.from_now + rand(8..20).hours,
    duration: [30, 60, 90, 120, 180, 240, 300].sample,
    price: rand(10..200),
    location: [
      "Paris, France",
      "Lyon, France", 
      "Marseille, France",
      "Toulouse, France",
      "Nice, France",
      "Bordeaux, France"
    ].sample,
    user: users.sample
  )
  events << event
  puts "✅ Événement créé : #{event.title} par #{event.user.first_name}"
end

puts "Création des participations..."

# Création des participations
30.times do |i|
  begin
    attendance = Attendance.create!(
      user: users.sample,
      event: events.sample,
      stripe_customer_id: "cus_#{SecureRandom.hex(12)}"
    )
    puts "✅ Participation créée : #{attendance.user.first_name} participe à #{attendance.event.title}"
  rescue ActiveRecord::RecordInvalid => e
    puts "⚠️  Participation déjà existante, on passe..."
  end
end

puts "🎉 Seeds terminées !"
puts "📊 Statistiques :"
puts "   - #{User.count} utilisateurs créés"
puts "   - #{Event.count} événements créés"
puts "   - #{Attendance.count} participations créées"