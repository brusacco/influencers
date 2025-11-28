# Integración con Instagram

## Overview

La aplicación se integra con Instagram a través de la API pública de Instagram usando Scrape.do como proxy para evitar limitaciones de CORS y rate limiting.

## Arquitectura

```
┌─────────────┐
│  Controller │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  InstagramServices  │
│  - GetProfileData   │
│  - UpdateProfileData│
│  - GetPostsData     │
│  - UpdatePostData   │
└──────┬──────────────┘
       │
       ▼
┌──────────────┐      ┌──────────────┐
│  Scrape.do   │─────▶│  Instagram   │
│   Proxy      │      │     API      │
└──────────────┘      └──────────────┘
```

## Configuración

### Variables de Entorno Requeridas

```bash
# Token de Scrape.do (requerido)
SCRAPE_DO_TOKEN=your_token_here

# Instagram App ID (opcional, tiene default)
INSTAGRAM_APP_ID=936619743392459

# Timeout de requests (opcional, default: 60s)
INSTAGRAM_API_TIMEOUT=60

# Rate limit (opcional, default: 30 req/min)
INSTAGRAM_RATE_LIMIT=30

# Logging (opcional, default: false)
LOG_INSTAGRAM_API_CALLS=true
```

### Obtener Token de Scrape.do

1. Registrarse en https://scrape.do
2. Obtener token de la dashboard
3. Agregar a `.env` como `SCRAPE_DO_TOKEN`

## Servicios Disponibles

### InstagramServices::GetProfileData

Obtiene datos crudos de un perfil de Instagram.

**Uso**:
```ruby
result = InstagramServices::GetProfileData.call('username')
if result.success?
  raw_data = result.data
else
  error_message = result.error
end
```

**Parámetros**:
- `username` (String): Username de Instagram (sin @)

**Retorna**:
- `success?` (Boolean): Si la operación fue exitosa
- `data` (Hash): Respuesta cruda de la API
- `error` (String): Mensaje de error si falló

**Errores Posibles**:
- `InvalidUsernameError`: Username inválido o vacío
- `APIError`: Error de la API (404, 429, 500, etc.)
- `TimeoutError`: Timeout en el request
- `ParseError`: Error al parsear JSON

**Ejemplo de Respuesta Exitosa**:
```ruby
{
  "data" => {
    "user" => {
      "id" => "123456789",
      "username" => "username",
      "full_name" => "Full Name",
      "biography" => "Bio text",
      "edge_followed_by" => { "count" => 10000 },
      # ... más campos
    }
  }
}
```

### InstagramServices::UpdateProfileData

Transforma datos crudos de Instagram en atributos para el modelo Profile.

**Uso**:
```ruby
raw_data = InstagramServices::GetProfileData.call('username').data
result = InstagramServices::UpdateProfileData.call(raw_data)
if result.success?
  profile.update!(result.data)
end
```

**Parámetros**:
- `data` (Hash): Respuesta cruda de `GetProfileData`

**Retorna**:
- `success?` (Boolean): Si la transformación fue exitosa
- `data` (Hash): Hash con atributos para `Profile`
- `error` (String): Mensaje de error si falló

**Campos Extraídos**:
- `followers`, `following`
- `profile_pic_url`, `profile_pic_url_hd`
- `is_business_account`, `is_professional_account`
- `category_name`, `business_category_name`
- `is_private`, `is_verified`
- `full_name`, `biography`
- `uid` (Instagram ID)

### InstagramServices::GetPostsData

Obtiene posts y videos (reels) de un perfil.

**Uso**:
```ruby
profile = Profile.find_by(username: 'username')
result = InstagramServices::GetPostsData.call(profile)
if result.success?
  posts = result.data  # Array de edges
end
```

**Parámetros**:
- `profile` (Profile): Instancia del modelo Profile

**Retorna**:
- `success?` (Boolean)
- `data` (Array): Array de edges (posts + videos combinados)
- `error` (String): Mensaje de error

**Nota**: Combina posts regulares (`edge_owner_to_timeline_media`) y videos/reels (`edge_felix_video_timeline`)

### InstagramServices::UpdatePostData

Transforma un edge de post en atributos para el modelo InstagramPost.

**Uso**:
```ruby
edge = result.data.first  # Primer post del array
post_result = InstagramServices::UpdatePostData.call(edge, cursor: true)
if post_result.success?
  post = profile.instagram_posts.find_or_create_by!(
    shortcode: edge['node']['shortcode']
  )
  post.update!(post_result.data)
end
```

**Parámetros**:
- `data` (Hash): Edge del array de posts
- `cursor` (Boolean, default: false): Si usa cursor mode (diferente campo para likes)

**Retorna**:
- `success?` (Boolean)
- `data` (Hash): Hash con atributos para `InstagramPost`
- `error` (String): Mensaje de error

**Campos Extraídos**:
- `shortcode`: Código único del post
- `url`: URL completa del post
- `caption`: Texto del caption
- `media`: Tipo de media (image, video, carousel)
- `posted_at`: Timestamp de publicación
- `likes_count`, `comments_count`, `video_view_count`
- `total_count`: Suma de likes + comments
- `data`: Edge completo (para debugging)

## Flujo Completo de Sincronización

### Sincronizar Perfil

```ruby
# 1. Obtener datos crudos
profile_data = InstagramServices::GetProfileData.call('username')
next unless profile_data.success?

# 2. Transformar datos
update_data = InstagramServices::UpdateProfileData.call(profile_data.data)
next unless update_data.success?

# 3. Actualizar modelo
profile = Profile.find_or_create_by!(username: 'username')
profile.update!(update_data.data)

# 4. Guardar avatar
profile.save_avatar
```

### Sincronizar Posts

```ruby
profile = Profile.find_by(username: 'username')

# 1. Obtener posts
posts_data = InstagramServices::GetPostsData.call(profile)
next unless posts_data.success?

# 2. Procesar cada post
posts_data.data.each do |edge|
  shortcode = edge['node']['shortcode']
  
  # Transformar datos
  post_data = InstagramServices::UpdatePostData.call(edge, cursor: true)
  next unless post_data.success?
  
  # Crear/actualizar post
  post = profile.instagram_posts.find_or_create_by!(shortcode: shortcode)
  post.update!(post_data.data)
  
  # Guardar imagen
  post.save_image(edge['node']['display_url'])
end
```

## Manejo de Errores

### Clasificación de Errores

El servicio `InstagramServices::ErrorClassifier` clasifica errores en:

- **Permanentes**: Perfil no existe, fue eliminado
  - Acción: Deshabilitar perfil (`enabled: false`)
  
- **Temporales**: Rate limit, timeout, error de red
  - Acción: Reintentar más tarde

- **Desconocidos**: Errores no clasificados
  - Acción: Loggear y no deshabilitar (conservador)

**Uso**:
```ruby
result = InstagramServices::GetProfileData.call('username')
unless result.success?
  error_info = InstagramServices::ErrorClassifier.describe(result.error)
  
  case error_info[:type]
  when :permanent
    profile.update!(enabled: false)
  when :temporary
    # Reintentar más tarde
  end
end
```

## Rate Limiting

- **Límite**: 30 requests por minuto (configurable)
- **Manejo**: Scrape.do maneja rate limiting automáticamente
- **Recomendación**: Agregar delays entre requests en rake tasks

## Retry Logic

Los servicios incluyen lógica de retry automática:

- **Max retries**: 3 (configurable)
- **Backoff**: Exponencial (2s, 4s, 8s)
- **Errores que se reintentan**: Timeout, conexión rechazada, errores de red

## Limitaciones

1. **API Pública**: Limitaciones de Instagram pueden cambiar sin aviso
2. **Rate Limits**: Scrape.do tiene sus propios límites
3. **Datos Disponibles**: Solo datos públicos (perfiles privados no accesibles)
4. **CORS**: Requiere proxy (Scrape.do) para requests desde navegador

## Troubleshooting

### Error 404 - Profile Not Found
- Verificar que el username sea correcto
- El perfil puede haber sido eliminado o cambiado de nombre
- Usar `ErrorClassifier` para determinar si es permanente

### Error 429 - Rate Limit
- Reducir frecuencia de requests
- Aumentar delays entre requests
- Verificar límites de Scrape.do

### Timeout Errors
- Aumentar `INSTAGRAM_API_TIMEOUT`
- Verificar conexión a internet
- Scrape.do puede estar sobrecargado

### Invalid JSON Response
- Puede indicar que Instagram cambió su estructura
- Verificar logs para ver respuesta completa
- Actualizar servicios si es necesario

## Referencias

- [Scrape.do Documentation](https://scrape.do/docs)
- [Instagram API (no oficial)](https://github.com/ping/instagram_private_api)
- [Código de Servicios](../app/services/instagram_services/)

