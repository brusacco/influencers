# API Authentication Documentation

## Configuración

### 1. Crear archivo .env

Crea un archivo `.env` en la raíz del proyecto con la siguiente variable:

```bash
API_TOKEN=tu_token_seguro_aqui
```

### 2. Generar un token seguro

Puedes generar un token seguro usando cualquiera de estos comandos:

```bash
# Opción 1: Usando Rails
rails secret

# Opción 2: Usando OpenSSL
openssl rand -hex 32

# Opción 3: Generar un UUID
uuidgen
```

### 3. Ejemplo de archivo .env

```bash
API_TOKEN=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

## Uso de la API

### Autenticación

La API requiere un token de autenticación que puede ser enviado de dos formas:

#### Opción 1: Query Parameter (recomendado para pruebas)

```bash
GET /api/v1/profiles/:username?token=YOUR_API_TOKEN
GET /api/v1/profiles/:username/posts?token=YOUR_API_TOKEN
```

#### Opción 2: Authorization Header (recomendado para producción)

```bash
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  http://localhost:3000/api/v1/profiles/ueno_py
```

## Endpoints

### 1. Obtener perfil

**URL:** `GET /api/v1/profiles/:username`

**Ejemplo:**

```bash
curl "http://localhost:3000/api/v1/profiles/ueno_py?token=YOUR_API_TOKEN"
```

**Respuesta exitosa (200):**

```json
{
  "id": 1,
  "username": "ueno_py",
  "full_name": "Juan Perez",
  "biography": "Developer",
  "followers": 1500,
  "engagement_rate": 5,
  ...
}
```

### 2. Obtener posts de un perfil

**URL:** `GET /api/v1/profiles/:username/posts`

**Ejemplo:**

```bash
curl "http://localhost:3000/api/v1/profiles/ueno_py/posts?token=YOUR_API_TOKEN"
```

**Respuesta exitosa (200):**

```json
{
  "profile_username": "ueno_py",
  "total_posts": 100,
  "posts": [
    {
      "id": 1,
      "shortcode": "ABC123",
      "caption": "Post caption",
      "likes_count": 150,
      ...
    }
  ]
}
```

## Respuestas de Error

### 401 Unauthorized - Token inválido o faltante

```json
{
  "error": "Unauthorized - Invalid or missing API token"
}
```

### 404 Not Found - Perfil no encontrado

```json
{
  "error": "Profile not found"
}
```

## Ejemplos con diferentes lenguajes

### JavaScript (fetch)

```javascript
const API_TOKEN = "your_api_token";
const username = "ueno_py";

// Opción 1: Query parameter
fetch(`http://localhost:3000/api/v1/profiles/${username}?token=${API_TOKEN}`)
  .then((response) => response.json())
  .then((data) => console.log(data));

// Opción 2: Authorization header
fetch(`http://localhost:3000/api/v1/profiles/${username}`, {
  headers: {
    Authorization: `Bearer ${API_TOKEN}`,
  },
})
  .then((response) => response.json())
  .then((data) => console.log(data));
```

### Python (requests)

```python
import requests

API_TOKEN = 'your_api_token'
username = 'ueno_py'

# Opción 1: Query parameter
response = requests.get(
    f'http://localhost:3000/api/v1/profiles/{username}',
    params={'token': API_TOKEN}
)

# Opción 2: Authorization header
response = requests.get(
    f'http://localhost:3000/api/v1/profiles/{username}',
    headers={'Authorization': f'Bearer {API_TOKEN}'}
)

data = response.json()
print(data)
```

### Ruby

```ruby
require 'net/http'
require 'json'

api_token = 'your_api_token'
username = 'ueno_py'

# Opción 1: Query parameter
uri = URI("http://localhost:3000/api/v1/profiles/#{username}?token=#{api_token}")
response = Net::HTTP.get_response(uri)
data = JSON.parse(response.body)

# Opción 2: Authorization header
uri = URI("http://localhost:3000/api/v1/profiles/#{username}")
request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{api_token}"
response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
data = JSON.parse(response.body)
```

## Seguridad

⚠️ **Importante:**

- Nunca compartas tu API token públicamente
- Agrega `.env` a tu `.gitignore` para evitar commitear tokens
- Usa HTTPS en producción para proteger el token en tránsito
- Rota el token periódicamente
- Considera usar diferentes tokens para diferentes ambientes (development, staging, production)

## Testing

Para probar la API localmente:

1. Configura tu token en `.env`
2. Reinicia el servidor Rails
3. Usa curl o Postman para hacer requests con el token

```bash
# Test básico
curl "http://localhost:3000/api/v1/profiles/ueno_py?token=YOUR_API_TOKEN"
```
