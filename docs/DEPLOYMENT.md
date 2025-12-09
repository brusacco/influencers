# 🚀 Guía de Deployment - Influencers App

## 📋 Pre-requisitos

- Ruby 3.3.0
- MySQL
- Redis
- Acceso al servidor de producción

---

## 🔐 Configuración de Variables de Entorno en Producción

### 1. Crear archivo `.env` en el servidor

```bash
# En el servidor de producción
cd /path/to/app
nano .env
```

### 2. Agregar las siguientes variables (MÍNIMO REQUERIDO):

```bash
# ====================================
# Instagram API Configuration
# ====================================
SCRAPE_DO_TOKEN=ed138ed418924138923ced2b81e04d53
INSTAGRAM_APP_ID=936619743392459
INSTAGRAM_API_TIMEOUT=60

# ====================================
# Rails Configuration
# ====================================
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# ====================================
# Secret Keys (GENERAR NUEVO)
# ====================================
SECRET_KEY_BASE=tu_secret_key_aqui_generado_con_rails_secret

# ====================================
# Database (si no usas database.yml)
# ====================================
# DATABASE_URL=mysql2://user:password@localhost/influencers_production
```

### 3. Generar SECRET_KEY_BASE

```bash
# En tu máquina local o servidor
cd /path/to/app
bundle exec rails secret
# Copia el resultado y pégalo en SECRET_KEY_BASE en el .env
```

---

## 🔒 Seguridad del archivo .env

### Permisos correctos en producción:

```bash
chmod 600 .env
chown deploy_user:deploy_user .env
```

### Verificar que .env NO está en git:

```bash
git status
# .env NO debe aparecer en la lista
```

---

## 📦 Deployment con Capistrano (recomendado)

Si usas Capistrano, agrega esto a tu `config/deploy.rb`:

```ruby
# Linked files para mantener .env entre deployments
set :linked_files, %w[.env config/database.yml config/master.key]
```

### Primera vez - Crear .env en servidor:

```bash
# En el servidor, en la carpeta shared
cd /path/to/app/shared
nano .env
# Pegar la configuración de producción
```

---

## 🐳 Deployment con Docker

Si usas Docker, hay dos opciones:

### Opción 1: Variables de entorno en docker-compose.yml

```yaml
version: '3.8'
services:
  web:
    build: .
    environment:
      - SCRAPE_DO_TOKEN=${SCRAPE_DO_TOKEN}
      - INSTAGRAM_APP_ID=${INSTAGRAM_APP_ID}
      - RAILS_ENV=production
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
    env_file:
      - .env
```

### Opción 2: Usar .env directamente

```dockerfile
# En tu Dockerfile
COPY .env .env
```

**⚠️ IMPORTANTE:** Si usas esta opción, asegúrate de que .env NO esté en la imagen pública de Docker.

---

## ✅ Verificar configuración en producción

### 1. Verificar que las variables se cargan:

```bash
cd /path/to/app
bundle exec rails console
```

```ruby
# En la consola de Rails
puts ENV['SCRAPE_DO_TOKEN']
# Debe mostrar tu token

puts InstagramConfig::SCRAPE_DO_TOKEN
# Debe mostrar tu token sin errores
```

### 2. Test de los servicios de Instagram:

```ruby
# En rails console production
result = InstagramServices::GetProfileData.call('instagram')
puts result.success? # Debe ser true
```

---

## 🔧 Comandos de Deployment

### Deployment estándar:

```bash
# 1. Pull del código
git pull origin main

# 2. Instalar dependencias
bundle install --deployment --without development test

# 3. Precompilar assets
RAILS_ENV=production bundle exec rails assets:precompile

# 4. Migrar database
RAILS_ENV=production bundle exec rails db:migrate

# 5. Reiniciar servidor
sudo systemctl restart puma
# o
touch tmp/restart.txt
```

---

## 📊 Tareas de Instagram (Rake Tasks)

Después del deployment, puedes correr las tareas de actualización:

```bash
# Actualizar estadísticas de profiles
RAILS_ENV=production bundle exec rake instagram:update_profiles_stats

# Actualizar posts
RAILS_ENV=production bundle exec rake instagram:update_posts

# Actualizar posts de marcas
RAILS_ENV=production bundle exec rake instagram:update_posts_marcas

# Actualizar posts de medios
RAILS_ENV=production bundle exec rake instagram:update_news_posts
```

---

## 🔍 Troubleshooting

### Error: "SCRAPE_DO_TOKEN environment variable is not set"

**Solución:**
```bash
# Verificar que .env existe
ls -la .env

# Verificar contenido (sin mostrar valores sensibles)
cat .env | grep SCRAPE_DO_TOKEN
```

### Error: "wrong number of arguments"

**Solución:** Asegúrate de que todos los servicios usan el nuevo formato:
```ruby
# ❌ Viejo formato
InstagramServices::UpdatePostData.call(edge, true)

# ✅ Nuevo formato
InstagramServices::UpdatePostData.call(edge, cursor: true)
```

### Logs no muestran llamadas de API

**Solución:** Habilita logging en `.env`:
```bash
LOG_INSTAGRAM_API_CALLS=true
```

---

## 🔄 Rollback en caso de problemas

```bash
# Si algo falla, volver a la versión anterior
git log --oneline -5  # Ver últimos commits
git checkout COMMIT_HASH_ANTERIOR
bundle install
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart puma
```

---

## 📝 Checklist de Deployment

- [ ] `.env` creado en producción con todas las variables
- [ ] `SECRET_KEY_BASE` generado y único
- [ ] Permisos de `.env` configurados (600)
- [ ] `.env` NO está en git
- [ ] `bundle install` completado
- [ ] Assets precompilados
- [ ] Migraciones ejecutadas
- [ ] Servidor reiniciado
- [ ] Verificación en rails console exitosa
- [ ] Rake tasks corriendo sin errores

---

## 🆘 Soporte

Si tienes problemas durante el deployment:

1. Revisa los logs: `tail -f log/production.log`
2. Verifica la configuración: `rails console` y prueba las variables
3. Revisa este documento para troubleshooting

---

**Última actualización:** $(date +%Y-%m-%d)

