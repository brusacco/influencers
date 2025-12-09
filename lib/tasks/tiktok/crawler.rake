# frozen_string_literal: true

require 'open3'
require 'json'
require 'shellwords'

namespace :tiktok do
  desc 'TikTok crawler - Cicla todos los perfiles y actualiza sus posts usando Node.js Playwright script'
  task crawler: :environment do
    script_path = File.join(Rails.root, 'profile_browser.js')
    
    unless File.exist?(script_path)
      puts "❌ Error: No se encuentra el script #{script_path}"
      puts "   Asegúrate de que profile_browser.js existe en la raíz del proyecto"
      exit 1
    end

    # Obtener todos los perfiles habilitados de TikTok
    profiles = TiktokProfile.enabled.where.not(username: nil).order(followers: :desc).to_a
    profiles_count = profiles.count

    if profiles_count.zero?
      puts "⚠️ No hay perfiles de TikTok habilitados para procesar"
      exit 0
    end

    puts "═══════════════════════════════════════════════════════"
    puts "🚀 Iniciando crawler de TikTok"
    puts "   Perfiles a procesar: #{profiles_count}"
    puts "   Script: #{script_path}"
    puts "═══════════════════════════════════════════════════════"
    puts ""

    total_posts_updated = 0
    total_posts_created = 0
    total_errors = 0
    profiles_processed = 0
    profiles_failed = 0

    profiles.each_with_index do |profile, index|
      profile_num = index + 1
      username = profile.username || profile.unique_id
      
      next if username.blank?

      puts "[#{Time.current.strftime('%H:%M:%S')}] [#{profile_num}/#{profiles_count}] Procesando @#{username} (#{profile.followers} seguidores)"
      puts "-" * 70

      begin
        # Ejecutar el script Node.js con el username del perfil
        # Usar Node.js v22 desde NVM
        cmd_args = ["--profile=#{username}", '--direct']
        
        # Agregar parámetros de proxy desde variables de entorno (.env)
        # Las variables deben estar definidas en .env con estos nombres:
        # http_proxyaddr, http_proxyport, http_proxyuser
        proxy_server = ENV['http_proxyaddr'] || ENV['HTTP_PROXYADDR']
        proxy_port = ENV['http_proxyport'] || ENV['HTTP_PROXYPORT']
        proxy_user = ENV['http_proxyuser'] || ENV['HTTP_PROXYUSER']
        proxy_password = ENV['http_proxypassword'] || ENV['HTTP_PROXYPASSWORD']
        
        if proxy_server.present? && proxy_port.present?
          cmd_args << "--proxy-server=#{proxy_server}"
          cmd_args << "--proxy-port=#{proxy_port}"
          cmd_args << "--proxy-user=#{proxy_user}" if proxy_user.present?
          cmd_args << "--proxy-password=#{proxy_password}" if proxy_password.present?
        end
        
        # Buscar Node.js v22 en NVM
        nvm_dir = ENV['NVM_DIR'] || File.expand_path('~/.nvm')
        node_v22_path = File.join(nvm_dir, 'versions/node/v22.20.0/bin/node')
        
        # Si no existe v22.20.0, buscar cualquier v22.x
        unless File.exist?(node_v22_path)
          v22_dirs = Dir.glob(File.join(nvm_dir, 'versions/node/v22.*/bin/node')).reverse
          node_v22_path = v22_dirs.first if v22_dirs.any?
        end
        
        # Si encontramos Node.js v22, usarlo; si no, usar nvm exec
        if node_v22_path && File.exist?(node_v22_path)
          stdout, stderr, status = Open3.capture3(node_v22_path, script_path, *cmd_args)
        else
          # Fallback: usar nvm exec
          nvm_cmd = "source #{nvm_dir}/nvm.sh && nvm use 22 > /dev/null 2>&1 && node #{script_path} #{cmd_args.map { |a| Shellwords.escape(a) }.join(' ')}"
          stdout, stderr, status = Open3.capture3('/bin/bash', '-c', nvm_cmd)
        end

        unless status.success?
          puts "  ✗ El script falló para @#{username}"
          if stderr && !stderr.empty?
            puts "     Error completo:"
            stderr.lines.each { |line| puts "     #{line}" }
          end
          if stdout && !stdout.empty? && stdout.length < 500
            puts "     Salida: #{stdout}"
          end
          profiles_failed += 1
          total_errors += 1
          puts ""
          next
        end

        # Parsear JSON retornado
        begin
          api_data = JSON.parse(stdout)
        rescue JSON::ParserError => e
          puts "  ✗ Error al parsear JSON para @#{username}: #{e.message}"
          if stdout && !stdout.empty?
            puts "     Salida: #{stdout.lines.first(5).join('     ')}"
          end
          profiles_failed += 1
          total_errors += 1
          puts ""
          next
        end

        # Extraer itemList del JSON
        # El JSON puede tener itemList directamente o dentro de data.itemList
        item_list = api_data['itemList'] || api_data.dig('data', 'itemList') || []
        
        unless item_list.is_a?(Array)
          puts "  ⚠ No se encontró itemList válido para @#{username}"
          profiles_failed += 1
          puts ""
          next
        end

        if item_list.empty?
          puts "  ⚠ No hay posts en itemList para @#{username}"
          puts ""
          next
        end

        # Procesar cada post del itemList
        posts_updated = 0
        posts_created = 0
        post_errors = 0

        item_list.each do |post_data|
          post_id = post_data['id']
          next if post_id.blank?

          post = profile.tiktok_posts.find_or_initialize_by(tiktok_post_id: post_id)
          was_new = post.new_record?

          begin
            # Usar UpdatePostData service para transformar los datos
            update_result = TiktokServices::UpdatePostData.call(post_data)
            
            if update_result.success?
              # Actualizar el post con los datos transformados
              post.update!(update_result.data)
              post.save_cover
              posts_updated += 1
              posts_created += 1 if was_new
            else
              puts "    ✗ Error al transformar post #{post_id}: #{update_result.error}"
              post_errors += 1
            end
          rescue StandardError => e
            puts "    ✗ Excepción en post #{post_id}: #{e.message}"
            post_errors += 1
          end
        end

        puts "  ✓ Procesados #{posts_updated} posts (#{posts_created} nuevos, #{post_errors} errores)"
        total_posts_updated += posts_updated
        total_posts_created += posts_created
        total_errors += post_errors
        profiles_processed += 1

      rescue Errno::ENOENT => e
        puts "  ✗ Error: No se encuentra 'node' en el PATH"
        puts "     Asegúrate de tener Node.js instalado"
        profiles_failed += 1
        total_errors += 1
      rescue StandardError => e
        puts "  ✗ Error inesperado para @#{username}: #{e.class} - #{e.message}"
        puts "     #{e.backtrace.first(3).join('     ')}"
        profiles_failed += 1
        total_errors += 1
      end

      puts ""
      
      # Pequeña pausa entre perfiles para no sobrecargar
      sleep(2) if profile_num < profiles_count
    end

    # Resumen final
    puts "═══════════════════════════════════════════════════════"
    puts "RESUMEN FINAL"
    puts "═══════════════════════════════════════════════════════"
    puts "Perfiles procesados: #{profiles_processed}/#{profiles_count}"
    puts "Perfiles fallidos: #{profiles_failed}"
    puts "✓ Total posts actualizados: #{total_posts_updated}"
    puts "✓ Total posts nuevos: #{total_posts_created}"
    puts "⚠ Total errores: #{total_errors}"
    puts "═══════════════════════════════════════════════════════"
  end
end
