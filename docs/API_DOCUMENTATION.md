# API Documentation

## Arquitectura de Serializadores

Esta API utiliza una arquitectura de serializadores organizada por red social, permitiendo escalar fácilmente a múltiples plataformas.

### Estructura Actual

```
app/serializers/
├── instagram/
│   └── serializers/
│       ├── base_serializer.rb      # Clase base para serializadores de Instagram
│       ├── profile_serializer.rb   # Serialización de perfiles
│       └── post_serializer.rb      # Serialización de posts
├── tiktok/                          # Preparado para TikTok (ejemplo incluido)
│   └── serializers/
└── README.md                        # Documentación de serializadores
```

## Endpoints Disponibles

### 1. Obtener Perfil de Instagram

**URL:** `GET /api/v1/profiles/:username`

**Autenticación:** Requerida (ver [API_AUTHENTICATION.md](API_AUTHENTICATION.md))

**Parámetros:**

- `username` (path, requerido): Username del perfil de Instagram
- `token` (query o header, requerido): Token de autenticación

**Ejemplo de Request:**

```bash
# Con query parameter
curl "http://localhost:3000/api/v1/profiles/ueno_py?token=YOUR_API_TOKEN"

# Con Authorization header
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  http://localhost:3000/api/v1/profiles/ueno_py
```

**Ejemplo de Respuesta Exitosa (200):**

```json
{
  "id": 1,
  "username": "ueno_py",
  "uid": "123456789",
  "full_name": "Juan Pérez",
  "biography": "Developer & Content Creator",
  "profile_type": "hombre",
  "followers": 1500,
  "following": 320,
  "is_verified": false,
  "is_business_account": true,
  "is_professional_account": true,
  "is_private": false,
  "is_joined_recently": false,
  "is_embeds_disabled": false,
  "country_string": "Paraguay",
  "category_name": "Technology",
  "category_enum": "tech",
  "business_category_name": "Computers & Technology",
  "profile_pic_url": "https://...",
  "profile_pic_url_hd": "https://...",
  "engagement_rate": 5,
  "total_posts": 150,
  "total_videos": 45,
  "total_likes_count": 12500,
  "total_comments_count": 850,
  "total_video_view_count": 25000,
  "total_interactions_count": 38350,
  "median_interactions": 255,
  "median_video_views": 555,
  "estimated_reach": 750,
  "estimated_reach_percentage": 50.0,
  "tags": ["tech", "developer", "python"],
  "created_at": "2023-01-15T10:30:00.000Z",
  "updated_at": "2024-11-10T15:45:00.000Z"
}
```

**Respuestas de Error:**

```json
// 401 Unauthorized - Token inválido o faltante
{
  "error": "Unauthorized - Invalid or missing API token"
}

// 404 Not Found - Perfil no encontrado
{
  "error": "Profile not found"
}
```

---

### 2. Obtener Posts Recientes Filtrados por Tipo de Perfil

**URL:** `GET /api/v1/posts`

**Autenticación:** Requerida (ver [API_AUTHENTICATION.md](API_AUTHENTICATION.md))

**Parámetros:**

- `profile_type` (query, opcional): Filtra por el tipo de perfil. Valores: `hombre`, `mujer`, `marca`, `medio`, `estatal`, `memes`, `programa`
- `token` (query o header, requerido): Token de autenticación

**Corte temporal:** Retorna publicaciones cuyo `posted_at` esté dentro de las últimas 24 horas, incluyendo perfiles sin restricción de estado o país.

**Ejemplo de Request:**

```bash
# Todos los tipos
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  "http://localhost:3000/api/v1/posts"

# Solo marcas
curl "http://localhost:3000/api/v1/posts?profile_type=marca&token=YOUR_API_TOKEN"
```

**Ejemplo de Respuesta Exitosa (200):**

```json
{
  "since": "2026-11-19T12:00:00Z",
  "profile_type": "marca",
  "total_posts": 1,
  "posts": [
    {
      "id": 1,
      "shortcode": "recent-brand",
      "profile_id": 1,
      "posted_at": "2026-11-20T10:00:00Z",
      "profile": {
        "id": 1,
        "username": "marca_example",
        "full_name": "Marca Example",
        "profile_pic_url": "https://..."
      }
    }
  ]
}
```

**Respuestas de Error:**

```json
// 422 Unprocessable Entity - Tipo de perfil invalido
{
  "error": "Invalid profile_type",
  "valid_profile_types": [
    "hombre",
    "mujer",
    "marca",
    "medio",
    "estatal",
    "memes",
    "programa"
  ]
}
```

---

### 3. Obtener Posts de un Perfil

**URL:** `GET /api/v1/profiles/:username/posts`

**Autenticación:** Requerida (ver [API_AUTHENTICATION.md](API_AUTHENTICATION.md))

**Parámetros:**

- `username` (path, requerido): Username del perfil de Instagram
- `token` (query o header, requerido): Token de autenticación

**Límite:** Retorna los últimos 100 posts ordenados por fecha de publicación

**Ejemplo de Request:**

```bash
# Con query parameter
curl "http://localhost:3000/api/v1/profiles/ueno_py/posts?token=YOUR_API_TOKEN"

# Con Authorization header
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  http://localhost:3000/api/v1/profiles/ueno_py/posts
```

**Ejemplo de Respuesta Exitosa (200):**

```json
{
  "profile_username": "ueno_py",
  "total_posts": 100,
  "posts": [
    {
      "id": 1234,
      "shortcode": "ABC123xyz",
      "url": "https://www.instagram.com/p/ABC123xyz/",
      "caption": "Check out this amazing content! #tech #developer",
      "media": "GraphImage",
      "product_type": "feed",
      "posted_at": "2024-11-10T12:00:00.000Z",
      "likes_count": 250,
      "comments_count": 15,
      "video_view_count": 0,
      "total_count": 265,
      "profile_id": 1,
      "created_at": "2024-11-10T12:05:00.000Z",
      "updated_at": "2024-11-10T15:30:00.000Z"
    },
    {
      "id": 1235,
      "shortcode": "DEF456uvw",
      "url": "https://www.instagram.com/p/DEF456uvw/",
      "caption": "Tutorial de Python 🐍",
      "media": "GraphVideo",
      "product_type": "feed",
      "posted_at": "2024-11-09T18:30:00.000Z",
      "likes_count": 180,
      "comments_count": 22,
      "video_view_count": 1200,
      "total_count": 1402,
      "profile_id": 1,
      "created_at": "2024-11-09T18:35:00.000Z",
      "updated_at": "2024-11-10T10:20:00.000Z"
    }
  ]
}
```

**Tipos de Media:**

- `GraphImage`: Imagen
- `GraphVideo`: Video
- `GraphSidecar`: Carrusel (múltiples imágenes/videos)

**Tipos de Producto:**

- `feed`: Post regular del feed
- `reels`: Reel
- `igtv`: IGTV
- `clips`: Clips

**Respuestas de Error:**

```json
// 401 Unauthorized - Token inválido o faltante
{
  "error": "Unauthorized - Invalid or missing API token"
}

// 404 Not Found - Perfil no encontrado
{
  "error": "Profile not found"
}
```

---

## Arquitectura y Extensibilidad

### Serializadores Organizados por Red Social

Los serializadores están organizados por namespace de red social, facilitando la adición de nuevas plataformas:

```ruby
# Instagram
Instagram::Serializers::ProfileSerializer.new(profile).as_json
Instagram::Serializers::PostSerializer.collection(posts)

# Futuro: TikTok
TikTok::Serializers::ProfileSerializer.new(profile).as_json
TikTok::Serializers::VideoSerializer.collection(videos)

# Futuro: Twitter/X
Twitter::Serializers::ProfileSerializer.new(profile).as_json
Twitter::Serializers::TweetSerializer.collection(tweets)
```

### Agregar Nueva Red Social

Para agregar soporte para una nueva red social:

1. Crear directorio `app/serializers/[network]/serializers/`
2. Crear clase base `[Network]::Serializers::BaseSerializer`
3. Crear serializadores específicos heredando de la base
4. Crear controladores API bajo `app/controllers/api/v1/[network]/`
5. Agregar rutas en `config/routes.rb`

Ver `app/serializers/README.md` para más detalles.

---

## Autenticación

Todos los endpoints requieren autenticación mediante token. Ver [API_AUTHENTICATION.md](API_AUTHENTICATION.md) para detalles completos.

**Métodos de autenticación soportados:**

1. **Query Parameter** (recomendado para pruebas):

   ```
   ?token=YOUR_API_TOKEN
   ```

2. **Authorization Header** (recomendado para producción):
   ```
   Authorization: Bearer YOUR_API_TOKEN
   ```

---

## Rate Limiting

Actualmente no hay límite de requests implementado. Se recomienda implementar rate limiting antes de producción.

---

## Paginación

Actualmente los posts están limitados a 100 resultados. Paginación estará disponible en una versión futura.

---

## Versionamiento

La API utiliza versionamiento en la URL:

- Versión actual: `/api/v1/`
- Futuras versiones: `/api/v2/`, `/api/v3/`, etc.

---

## Códigos de Estado HTTP

- `200 OK`: Request exitoso
- `401 Unauthorized`: Token inválido o faltante
- `404 Not Found`: Recurso no encontrado
- `500 Internal Server Error`: Error del servidor

---

## Soporte

Para reportar issues o solicitar features, contacta al equipo de desarrollo.
