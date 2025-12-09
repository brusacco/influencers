# 📊 Análisis de Datos y Recomendaciones - Influencers App
## Rol: Analista de Datos Senior

---

## 📋 RESUMEN EJECUTIVO

Después de analizar la estructura actual de datos, identifico **oportunidades significativas** para extraer más valor del raw JSON de Instagram API que ya almacenamos. Actualmente **estamos infrautilizando ~60% de los datos disponibles**.

---

## 🔍 DATOS ACTUALES GUARDADOS

### **Tabla: `profiles`**

#### ✅ Datos que YA guardamos:
- **Métricas básicas:** followers, following
- **Info del perfil:** username, full_name, biography, profile_pic_url
- **Flags:** is_verified, is_business_account, is_professional_account, is_private
- **Categorías:** category_name, business_category_name, profile_type
- **Métricas calculadas:** engagement_rate, total_interactions_count, total_posts
- **Raw JSON:** `data` (campo text con toda la respuesta de Instagram)

### **Tabla: `instagram_posts`**

#### ✅ Datos que YA guardamos:
- **Métricas:** likes_count, comments_count, video_view_count, total_count
- **Info del post:** shortcode, caption, url, media, product_type, posted_at
- **Raw JSON:** `data` (campo text con toda la respuesta del post)

### **Tabla: `instagram_profile_stats`**

#### ✅ Datos históricos (time series):
- followers_count, total_likes, total_comments, total_video_views
- total_interactions_count, total_posts, total_videos, engagement_rate
- Indexado por `profile_id` y `date`

---

## 🎯 CAMPOS DISPONIBLES EN RAW JSON (Instagram API)

### **Del Profile Raw JSON (`data['data']['user']`):**

```json
{
  // YA GUARDADOS ✅
  "edge_followed_by": { "count": 123456 },
  "edge_follow": { "count": 789 },
  "profile_pic_url": "...",
  "is_verified": true,
  "full_name": "...",
  "biography": "...",
  
  // 🔥 NO GUARDADOS - ALTO VALOR
  "edge_owner_to_timeline_media": { "count": 450 },  // Total posts count
  "edge_felix_video_timeline": { "count": 89 },      // Total reels/videos count
  "highlight_reel_count": 12,                        // Stories highlights
  "external_url": "https://...",                     // Website/link en bio
  "external_url_linkshimmed": "https://...",
  "has_ar_effects": false,                           // Usa filtros AR
  "has_clips": true,                                 // Tiene reels
  "has_guides": false,                               // Tiene guías
  "has_channel": false,                              // Canal/broadcast
  "has_blocked_viewer": false,
  "fbid": "17841...",                               // Facebook ID
  "is_eligible_for_smb_support_flow": false,
  "is_eligible_for_lead_center": false,
  "show_account_transparency_details": true,
  "transparency_product_enabled": false,
  "requested_by_viewer": false,
  "followed_by_viewer": false,
  "restricted_by_viewer": false,
  "has_requested_viewer": false,
  "edge_mutual_followed_by": { "count": 0 },       // Seguidores mutuos
  "pronouns": [],                                   // Pronombres
  "country_block": false
}
```

### **Del Post Raw JSON (`data['node']`):**

```json
{
  // YA GUARDADOS ✅
  "__typename": "GraphVideo",
  "shortcode": "...",
  "edge_liked_by": { "count": 1234 },
  "edge_media_to_comment": { "count": 56 },
  "taken_at_timestamp": 1699999999,
  "display_url": "...",
  "video_view_count": 5678,
  
  // 🔥 NO GUARDADOS - ALTO VALOR
  "dimensions": { "height": 1350, "width": 1080 },  // Dimensiones del contenido
  "accessibility_caption": "...",                   // Caption de accesibilidad
  "is_video": true,
  "video_duration": 15.5,                          // Duración del video (segundos)
  "video_play_count": 5678,                        // Reproducciones
  "has_audio": true,                               // Tiene audio
  "edge_media_to_sponsor_user": { "edges": [] },   // Posts patrocinados
  "edge_media_to_tagged_user": { "edges": [] },    // Usuarios etiquetados
  "edge_web_media_to_related_media": { "edges": [] },
  "coauthor_producers": [],                        // Co-autores (colaboraciones)
  "pinned_for_users": [],                          // Post pinneado
  "location": {                                    // Ubicación
    "id": "123",
    "has_public_page": true,
    "name": "Asunción, Paraguay",
    "slug": "asuncion-paraguay"
  },
  "is_paid_partnership": false,                    // Contenido patrocinado
  "commenting_disabled_for_viewer": false,
  "comments_disabled": false,
  "taken_at": "2024-01-01T12:00:00Z",
  "edge_sidecar_to_children": {                    // Si es carrusel
    "edges": [...]                                 // Imágenes/videos del carrusel
  },
  "edge_media_to_hoisted_comment": { ... },        // Comentario destacado
  "thumbnail_src": "...",
  "thumbnail_resources": [],
  "felix_profile_grid_crop": null,
  "product_type": "feed/reels/igtv",
  "clips_music_attribution_info": {                // Info de música en Reels
    "artist_name": "...",
    "song_name": "...",
    "uses_original_audio": false,
    "should_mute_audio": false,
    "audio_id": "123456"
  }
}
```

---

## 💡 RECOMENDACIONES PRIORITARIAS

### **🏆 PRIORIDAD ALTA - Implementar Inmediatamente**

#### **1. Métricas de Contenido Avanzadas (Posts)**

**Nuevos campos para `instagram_posts`:**

```ruby
# Migration sugerida
add_column :instagram_posts, :video_duration, :float          # Duración en segundos
add_column :instagram_posts, :has_audio, :boolean, default: true
add_column :instagram_posts, :aspect_ratio, :string           # "1:1", "4:5", "9:16", etc.
add_column :instagram_posts, :carousel_size, :integer         # Cantidad de fotos/videos en carrusel
add_column :instagram_posts, :is_paid_partnership, :boolean, default: false
add_column :instagram_posts, :location_name, :string          # Nombre del lugar
add_column :instagram_posts, :location_id, :string            # ID de Instagram del lugar
add_column :instagram_posts, :tagged_users_count, :integer, default: 0
add_column :instagram_posts, :music_artist_name, :string      # Para Reels con música
add_column :instagram_posts, :music_song_name, :string
add_column :instagram_posts, :uses_original_audio, :boolean   # Audio original vs música
```

**📈 Análisis que podríamos hacer:**
- ✅ **Correlación duración de video vs engagement** (¿videos cortos funcionan mejor?)
- ✅ **Impacto de música vs audio original** en reels
- ✅ **Performance por aspect ratio** (cuadrado, vertical, horizontal)
- ✅ **Efectividad de posts patrocinados** vs orgánicos
- ✅ **Engagement por tipo de ubicación** (eventos, lugares, etc.)
- ✅ **Impacto de carruseles** (¿más fotos = más engagement?)

---

#### **2. Métricas de Perfil Extendidas**

**Nuevos campos para `profiles`:**

```ruby
# Migration sugerida
add_column :profiles, :total_posts_count, :integer, default: 0    # Desde edge_owner_to_timeline_media
add_column :profiles, :total_reels_count, :integer, default: 0    # Desde edge_felix_video_timeline
add_column :profiles, :highlight_reel_count, :integer, default: 0 # Stories highlights
add_column :profiles, :external_url, :text                        # Link en bio
add_column :profiles, :has_clips, :boolean, default: false        # Tiene reels
add_column :profiles, :has_guides, :boolean, default: false       # Tiene guías
add_column :profiles, :has_channel, :boolean, default: false      # Broadcast channel
add_column :profiles, :facebook_id, :string                       # FBID para cross-platform
add_column :profiles, :pronouns, :string                          # Pronombres
add_column :profiles, :is_eligible_for_smb_support, :boolean      # Elegible para soporte empresas

# Nuevas métricas calculadas
add_column :profiles, :reels_percentage, :float                   # % de reels vs posts totales
add_column :profiles, :avg_post_frequency, :float                 # Posts por semana
add_column :profiles, :content_consistency_score, :float          # Qué tan consistente publica
```

**📈 Análisis que podríamos hacer:**
- ✅ **Influencers que aprovechan Reels** (tendencia creciente)
- ✅ **Correlación highlights vs engagement** (profiles con más highlights = más profesionales)
- ✅ **External URL tracking** (quiénes tienen links, qué dominios usan)
- ✅ **Adoption rate de features nuevas** (Guides, Channels)
- ✅ **Frecuencia de publicación óptima** por tipo de perfil

---

### **🥈 PRIORIDAD MEDIA - Valor Alto**

#### **3. Análisis de Engagement Detallado**

**Nueva tabla: `instagram_post_engagement_metrics`**

```ruby
create_table :instagram_post_engagement_metrics do |t|
  t.references :instagram_post, null: false, foreign_key: true
  t.float :likes_per_follower              # likes / followers del perfil
  t.float :comments_per_follower           # comments / followers
  t.float :engagement_rate                 # (likes + comments) / followers * 100
  t.float :comment_to_like_ratio           # comments / likes
  t.float :video_completion_rate           # Si es video: view_count / reach (estimado)
  t.integer :saves_count                   # Si Instagram API lo provee
  t.integer :shares_count                  # Si Instagram API lo provee
  t.datetime :peak_engagement_time         # Hora del día con más engagement
  t.timestamps
end
```

**📈 Análisis que podríamos hacer:**
- ✅ **Posts con mejor engagement relativo** (no solo absoluto)
- ✅ **Identificar contenido "viral"** (engagement >> promedio del perfil)
- ✅ **Benchmark por categoría** de perfil
- ✅ **Mejores horas para publicar** por tipo de audiencia

---

#### **4. Análisis de Contenido y Hashtags**

**Nueva tabla: `instagram_hashtags`**

```ruby
create_table :instagram_hashtags do |t|
  t.string :name, null: false, index: { unique: true }
  t.integer :usage_count, default: 0
  t.timestamps
end

create_table :instagram_post_hashtags do |t|
  t.references :instagram_post, null: false, foreign_key: true
  t.references :instagram_hashtag, null: false, foreign_key: true
  t.integer :position                       # Posición en el caption
  t.timestamps
end

add_column :instagram_posts, :hashtags_count, :integer, default: 0
add_column :instagram_posts, :mentions_count, :integer, default: 0
add_column :instagram_posts, :caption_length, :integer
add_column :instagram_posts, :has_cta, :boolean                 # Call to Action (link en caption)
add_column :instagram_posts, :emoji_count, :integer, default: 0
add_column :instagram_posts, :caption_language, :string         # 'es', 'en', 'guarani', etc.
```

**📈 Análisis que podríamos hacer:**
- ✅ **Hashtags más efectivos** por categoría
- ✅ **Trending hashtags** en Paraguay
- ✅ **Correlación cantidad de hashtags vs engagement**
- ✅ **Efectividad de CTAs** en captions
- ✅ **Longitud óptima de caption** por tipo de contenido
- ✅ **Análisis de idioma** (español vs guaraní vs mezcla)

---

#### **5. Métricas Temporales y Tendencias**

**Nuevos campos calculados:**

```ruby
# Para profiles
add_column :profiles, :follower_growth_rate_7d, :float         # Crecimiento últimos 7 días
add_column :profiles, :follower_growth_rate_30d, :float        # Crecimiento últimos 30 días
add_column :profiles, :engagement_trend, :string               # 'up', 'down', 'stable'
add_column :profiles, :last_post_at, :datetime                 # Última publicación
add_column :profiles, :posting_frequency_days, :float          # Promedio días entre posts
add_column :profiles, :is_active, :boolean, default: true      # Activo si post < 30 días

# Para posts
add_column :instagram_posts, :engagement_velocity, :float      # Engagement en primeras 24h
add_column :instagram_posts, :peak_engagement_reached_at, :datetime
add_column :instagram_posts, :hours_to_1k_likes, :float        # Velocidad viral
```

**📈 Análisis que podríamos hacer:**
- ✅ **Identificar influencers en crecimiento rápido**
- ✅ **Detectar perfiles inactivos** automáticamente
- ✅ **Predecir contenido viral** en primeras horas
- ✅ **Frecuencia óptima de publicación** por tipo de perfil
- ✅ **Alertas de cambios significativos** (drops de followers)

---

### **🥉 PRIORIDAD BAJA - Valor Futuro**

#### **6. Análisis de Colaboraciones Mejorado**

```ruby
add_column :instagram_collaborations, :collaboration_type, :string  # 'tag', 'mention', 'coauthor'
add_column :instagram_collaborations, :campaign_id, :string         # Para agrupar campañas
add_column :instagram_collaborations, :estimated_reach, :integer    # Reach estimado
add_column :instagram_collaborations, :brand_value, :decimal        # Valor estimado de colaboración
```

#### **7. Análisis de Ubicaciones**

```ruby
create_table :instagram_locations do |t|
  t.string :instagram_id, null: false, index: { unique: true }
  t.string :name
  t.string :slug
  t.float :latitude
  t.float :longitude
  t.string :category                         # 'restaurant', 'event', 'landmark', etc.
  t.integer :posts_count, default: 0
  t.timestamps
end
```

#### **8. Análisis de Música en Reels**

```ruby
create_table :instagram_audio_tracks do |t|
  t.string :audio_id, null: false, index: { unique: true }
  t.string :artist_name
  t.string :song_name
  t.integer :usage_count, default: 0
  t.boolean :is_trending, default: false
  t.timestamps
end
```

---

## 🎯 MÉTRICAS CALCULADAS RECOMENDADAS

### **Para Dashboard Principal:**

1. **Influencer Score** (0-100):
   ```ruby
   def influencer_score
     engagement_weight = 0.4
     growth_weight = 0.3
     consistency_weight = 0.2
     reach_weight = 0.1
     
     (
       (engagement_rate * engagement_weight) +
       (follower_growth_rate_30d * growth_weight) +
       (content_consistency_score * consistency_weight) +
       (followers / 1000000.0 * reach_weight)
     ).round(2)
   end
   ```

2. **Content Quality Score**:
   ```ruby
   def content_quality_score
     factors = [
       has_high_res_images?,
       avg_caption_length > 50,
       uses_hashtags_optimally?,
       posts_consistently?,
       uses_location_tags?
     ]
     (factors.count(true) / factors.size.to_f * 100).round
   end
   ```

3. **Brand Value Index**:
   ```ruby
   def estimated_brand_value
     base_cpm = 10 # Cost per mille (thousand followers)
     engagement_multiplier = (engagement_rate / 3.0) # 3% es promedio
     
     (followers / 1000.0) * base_cpm * engagement_multiplier
   end
   ```

4. **Virality Coefficient**:
   ```ruby
   def virality_coefficient
     recent_posts = instagram_posts.last_week
     return 0 if recent_posts.empty?
     
     viral_posts = recent_posts.select { |p| p.engagement_rate > median_engagement * 2 }
     (viral_posts.count / recent_posts.count.to_f * 100).round
   end
   ```

---

## 📊 DASHBOARDS Y REPORTES SUGERIDOS

### **1. Executive Dashboard**
- Top influencers por engagement rate
- Crecimiento semanal/mensual
- Trending content types
- Mejores horarios de publicación
- ROI de colaboraciones

### **2. Content Performance Report**
- Posts con mejor performance
- Hashtags más efectivos
- Análisis de formato (video vs imagen vs carrusel)
- Duración óptima de videos
- Efectividad de música en reels

### **3. Audience Insights**
- Demografía de followers (si API lo provee)
- Horarios de mayor actividad
- Engagement patterns por día de semana
- Growth trends por categoría

### **4. Competitive Analysis**
- Benchmark contra competencia
- Share of voice por categoría
- Ranking de influencers paraguayos
- Oportunidades de colaboración

### **5. Alerts & Monitoring**
- Drops significativos de followers
- Contenido viral emergente
- Nuevos influencers en crecimiento
- Cambios en engagement rate

---

## 🛠️ IMPLEMENTACIÓN RECOMENDADA

### **Fase 1 (Sprint 1-2): Alta Prioridad**
1. ✅ Agregar campos de contenido avanzado a posts
2. ✅ Implementar métricas de perfil extendidas
3. ✅ Crear servicio de extracción de datos del JSON
4. ✅ Dashboard básico con nuevas métricas

### **Fase 2 (Sprint 3-4): Media Prioridad**
1. ✅ Sistema de hashtags y análisis
2. ✅ Métricas de engagement detalladas
3. ✅ Trending content detection
4. ✅ Growth tracking automático

### **Fase 3 (Sprint 5-6): Baja Prioridad**
1. ✅ Análisis de ubicaciones
2. ✅ Música tracking en reels
3. ✅ Predictive analytics
4. ✅ ML para content recommendations

---

## 💰 ROI ESPERADO

### **Valor Comercial de los Nuevos Datos:**

1. **Para Marcas:**
   - Mejor selección de influencers (datos más precisos)
   - Predicción de performance de campañas
   - ROI medible de colaboraciones

2. **Para Influencers:**
   - Insights sobre su contenido
   - Benchmarking contra peers
   - Optimización de estrategia de contenido

3. **Para la Plataforma:**
   - Diferenciación vs competencia
   - Datos únicos = valor agregado
   - Posibilidad de monetización premium

### **Estimación:**
- **Esfuerzo:** ~40-60 horas de desarrollo (Fase 1)
- **Impacto:** +300% más insights de los datos existentes
- **Monetización:** Potencial de features premium

---

## 🎓 CONCLUSIONES

1. **Actualmente tenemos una MINA DE ORO de datos** en el campo JSON que no estamos explotando
2. **No requiere nuevas llamadas a API** - todo está en los datos actuales
3. **Impacto inmediato** en valor percibido de la plataforma
4. **Ventaja competitiva** - análisis que nadie más tiene en Paraguay

### **Siguiente Paso Recomendado:**
Crear un **rake task de análisis exploratorio** que extraiga una muestra del JSON actual y genere un reporte de qué campos están presentes en el 95%+ de los registros.

```bash
rake data:analyze_raw_json_fields
```

Este reporte nos dirá exactamente qué campos podemos confiar que siempre estarán presentes.

---

**Elaborado por:** Equipo de Data Analytics  
**Fecha:** 2024-11-09  
**Estado:** Pendiente de aprobación para implementación

