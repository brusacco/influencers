# frozen_string_literal: true

namespace :ai do
  desc 'Classify profiles using OpenAI API'
  task classify_profiles: :environment do
    Profile.order(followers: :desc).limit(1).each do |profile|
      puts "Updating #{profile.username}"

      response = InstagramServices::UpdateProfileData.call(profile.data)
      data = response.data

      prompt = "clasificar la siguiente cuenta de Instagram, username: #{profile.username} en las categorias
      hombre, mujer o marca analizando los siguientes datos JSON #{data} de perfil
      toma en cuenta parametros como biography, full_name, y el username
      retorna una de las 3 opciones: hombre, mujer o marca
      solo retorna la palabra y no agregues ningun coimentario adicional"

      response = AiServices::OpenAiQuery.call(prompt)
      puts response.data
      puts '-----------------------------------------'
    end
  end
end
