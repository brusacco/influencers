# frozen_string_literal: true

namespace :data do
  desc 'Analyze raw JSON fields from Instagram profiles and posts'
  task analyze_raw_json_fields: :environment do
    puts "\n" + "="*80
    puts "📊 ANÁLISIS DE CAMPOS RAW JSON - INSTAGRAM DATA"
    puts "="*80 + "\n"

    analyze_profiles
    puts "\n"
    analyze_posts
    puts "\n"
    generate_summary
  end

  def analyze_profiles
    puts "🔍 Analizando Profiles..."
    puts "-" * 80

    profiles = Profile.paraguayos.where.not(data: nil).limit(100)
    total = profiles.count

    return puts "❌ No hay profiles con data JSON" if total.zero?

    # Campos a analizar
    profile_fields = {}

    profiles.each do |profile|
      next unless profile.data.is_a?(Hash)
      next unless profile.data.dig('data', 'user')

      user = profile.data['data']['user']
      analyze_hash_fields(user, profile_fields)
    end

    puts "\n📋 CAMPOS DISPONIBLES EN PROFILE (aparecen en #{total} profiles):\n"
    
    profile_fields.sort_by { |_k, v| -v }.each do |field, count|
      percentage = (count.to_f / total * 100).round(1)
      status = percentage >= 95 ? "✅" : percentage >= 50 ? "⚠️" : "❌"
      puts "#{status} #{field.ljust(50)} | #{count}/#{total} (#{percentage}%)"
    end

    # Mostrar valores de ejemplo para campos interesantes
    puts "\n📝 VALORES DE EJEMPLO:\n"
    sample_profile = profiles.first
    if sample_profile&.data.is_a?(Hash)
      user = sample_profile.data.dig('data', 'user')
      interesting_fields = [
        'edge_owner_to_timeline_media',
        'edge_felix_video_timeline',
        'highlight_reel_count',
        'external_url',
        'has_clips',
        'has_guides',
        'fbid'
      ]

      interesting_fields.each do |field|
        value = user[field]
        next if value.nil?
        
        display_value = value.is_a?(Hash) ? value.inspect[0..100] : value.to_s
        puts "  • #{field}: #{display_value}"
      end
    end
  end

  def analyze_posts
    puts "\n🔍 Analizando Posts..."
    puts "-" * 80

    posts = InstagramPost.where.not(data: nil).order(posted_at: :desc).limit(100)
    total = posts.count

    return puts "❌ No hay posts con data JSON" if total.zero?

    # Campos a analizar
    post_fields = {}

    posts.each do |post|
      next unless post.data.is_a?(Hash)
      next unless post.data['node']

      node = post.data['node']
      analyze_hash_fields(node, post_fields)
    end

    puts "\n📋 CAMPOS DISPONIBLES EN POST (aparecen en #{total} posts):\n"
    
    post_fields.sort_by { |_k, v| -v }.each do |field, count|
      percentage = (count.to_f / total * 100).round(1)
      status = percentage >= 95 ? "✅" : percentage >= 50 ? "⚠️" : "❌"
      puts "#{status} #{field.ljust(50)} | #{count}/#{total} (#{percentage}%)"
    end

    # Análisis de tipos de contenido
    puts "\n📊 TIPOS DE CONTENIDO:\n"
    media_types = posts.group_by(&:media).transform_values(&:count)
    media_types.each do |type, count|
      percentage = (count.to_f / total * 100).round(1)
      puts "  • #{type}: #{count} (#{percentage}%)"
    end

    # Análisis de videos
    video_posts = posts.select { |p| p.data.is_a?(Hash) && p.data.dig('node', 'video_duration') }
    if video_posts.any?
      durations = video_posts.map { |p| p.data['node']['video_duration'] }
      avg_duration = (durations.sum / durations.size.to_f).round(2)
      puts "\n📹 VIDEOS:\n"
      puts "  • Total con duración: #{video_posts.count}"
      puts "  • Duración promedio: #{avg_duration} segundos"
      puts "  • Duración min: #{durations.min} seg"
      puts "  • Duración max: #{durations.max} seg"
    end

    # Análisis de ubicaciones
    location_posts = posts.select { |p| p.data.is_a?(Hash) && p.data.dig('node', 'location') }
    puts "\n📍 UBICACIONES:\n"
    puts "  • Posts con ubicación: #{location_posts.count} (#{(location_posts.count.to_f/total*100).round(1)}%)"
    
    if location_posts.any?
      sample_locations = location_posts.first(5).map { |p| p.data.dig('node', 'location', 'name') }.compact
      puts "  • Ejemplos: #{sample_locations.join(', ')}"
    end

    # Análisis de música en reels
    music_posts = posts.select { |p| p.data.is_a?(Hash) && p.data.dig('node', 'clips_music_attribution_info') }
    puts "\n🎵 MÚSICA EN REELS:\n"
    puts "  • Posts con música: #{music_posts.count} (#{(music_posts.count.to_f/total*100).round(1)}%)"
    
    if music_posts.any?
      sample_music = music_posts.first(3).map do |p|
        info = p.data.dig('node', 'clips_music_attribution_info')
        "#{info['artist_name']} - #{info['song_name']}" if info
      end.compact
      puts "  • Ejemplos:\n#{sample_music.map { |m| "    - #{m}" }.join("\n")}"
    end

    # Mostrar estructura completa de un post
    puts "\n📝 ESTRUCTURA COMPLETA DE UN POST (ejemplo):\n"
    sample_post = posts.first
    if sample_post&.data.is_a?(Hash) && sample_post.data['node']
      puts JSON.pretty_generate(sample_post.data['node'].except('edge_media_to_caption', 'display_url', 'thumbnail_src'))
    end
  end

  def analyze_hash_fields(hash, field_counter, prefix = '')
    hash.each do |key, value|
      full_key = prefix.empty? ? key : "#{prefix}.#{key}"
      
      field_counter[full_key] ||= 0
      field_counter[full_key] += 1

      # Recursivamente analizar hashes anidados (max 2 niveles)
      if value.is_a?(Hash) && prefix.split('.').size < 2
        analyze_hash_fields(value, field_counter, full_key)
      end
    end
  end

  def generate_summary
    puts "="*80
    puts "💡 RESUMEN Y RECOMENDACIONES"
    puts "="*80

    profiles_count = Profile.paraguayos.where.not(data: nil).count
    posts_count = InstagramPost.where.not(data: nil).count

    puts "\n📈 VOLUMEN DE DATOS:"
    puts "  • Profiles con raw JSON: #{profiles_count}"
    puts "  • Posts con raw JSON: #{posts_count}"
    puts "  • Total de datos disponibles: #{(profiles_count + posts_count)} registros"

    puts "\n🎯 PRÓXIMOS PASOS:"
    puts "  1. Revisar el archivo DATA_ANALYSIS_RECOMMENDATIONS.md"
    puts "  2. Priorizar campos con ✅ (presentes en >95% de registros)"
    puts "  3. Crear migraciones para agregar nuevos campos"
    puts "  4. Implementar extractores de datos del JSON"
    puts "  5. Actualizar servicios de Instagram para guardar nuevos campos"

    puts "\n📚 DOCUMENTACIÓN:"
    puts "  • Ver: DATA_ANALYSIS_RECOMMENDATIONS.md para análisis completo"
    puts "  • Implementar: Fase 1 (campos de alta prioridad)"
    
    puts "\n✅ Análisis completado!\n"
  end
end

