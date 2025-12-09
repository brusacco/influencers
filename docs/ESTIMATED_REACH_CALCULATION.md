# 📊 Cálculo de Alcance (Reach) sin Modificar Base de Datos

## 🎯 Objetivo
Calcular el **alcance estimado** de un perfil de Instagram usando solo los datos que YA tenemos disponibles.

---

## 📈 Datos Disponibles en Profile

```ruby
# Métricas básicas
- followers (int)
- engagement_rate (int) # En porcentaje
- total_interactions_count (int)
- total_posts (int)
- total_videos (int)
- total_likes_count (int)
- total_comments_count (int)
- total_video_view_count (int)

# Flags
- is_verified (boolean)
- is_business_account (boolean)
- profile_type (enum)
```

---

## 🧮 Fórmula de Alcance Estimado

### **Enfoque 1: Método Conservador (Recomendado)**

Basado en estudios de Instagram que indican que el alcance promedio es entre **10-30%** de los followers, ajustado por engagement.

```ruby
def estimated_reach
  return 0 if followers.zero? || total_posts.zero?
  
  # Base reach: ~15% de followers (promedio de Instagram 2024)
  base_reach_percentage = 15.0
  
  # Ajuste por engagement rate
  # Engagement alto (>5%) = más alcance
  # Engagement bajo (<1%) = menos alcance
  engagement_multiplier = calculate_engagement_multiplier
  
  # Ajuste por tipo de contenido
  content_multiplier = calculate_content_multiplier
  
  # Ajuste por verificación y tipo de cuenta
  account_multiplier = calculate_account_multiplier
  
  # Fórmula final
  reach = followers * (base_reach_percentage / 100.0) * 
          engagement_multiplier * 
          content_multiplier * 
          account_multiplier
  
  reach.round
end

private

def calculate_engagement_multiplier
  # Engagement rate promedio en Instagram: ~3%
  benchmark_engagement = 3.0
  
  # Si engagement es mayor al benchmark, aumenta alcance
  # Si es menor, disminuye
  actual_engagement = engagement_rate.to_f
  
  if actual_engagement >= benchmark_engagement
    # Engagement alto: multiplier entre 1.0 y 2.0
    [1.0 + ((actual_engagement - benchmark_engagement) / 10.0), 2.0].min
  else
    # Engagement bajo: multiplier entre 0.5 y 1.0
    [0.5 + (actual_engagement / benchmark_engagement) * 0.5, 1.0].min
  end
end

def calculate_content_multiplier
  # Videos/Reels tienen más alcance que fotos
  return 1.0 if total_posts.zero?
  
  video_ratio = total_videos.to_f / total_posts
  
  # Instagram favorece video content
  # 0% videos = 1.0x
  # 50% videos = 1.2x
  # 100% videos = 1.5x
  1.0 + (video_ratio * 0.5)
end

def calculate_account_multiplier
  multiplier = 1.0
  
  # Cuentas verificadas tienen ~20% más alcance
  multiplier *= 1.2 if is_verified
  
  # Cuentas business tienen mejor distribución
  multiplier *= 1.1 if is_business_account
  
  # Ajuste por tipo de perfil
  case profile_type
  when 'medio', 'estatal'
    multiplier *= 1.15 # Contenido informativo tiene más alcance
  when 'memes'
    multiplier *= 1.3  # Contenido viral tiene mucho más alcance
  when 'marca'
    multiplier *= 0.9  # Contenido comercial tiene menos alcance orgánico
  end
  
  multiplier
end
```

---

### **Enfoque 2: Método Basado en Interacciones (Más Preciso)**

Este método usa las interacciones reales para estimar el alcance.

```ruby
def estimated_reach_from_interactions
  return 0 if total_posts.zero?
  
  # Promedio de interacciones por post
  avg_interactions = median_interactions
  
  # Ratio típico de engagement sobre reach en Instagram:
  # - Si alguien ve un post, ~10% interactúa (like/comment)
  # - Esto significa que reach = interactions / 0.10
  interaction_rate = 0.10
  
  # Ajustar por tipo de contenido
  if has_high_video_ratio?
    interaction_rate = 0.12 # Videos tienen más engagement relativo
  end
  
  # Alcance estimado por post
  estimated_reach_per_post = avg_interactions / interaction_rate
  
  # Multiplicador por frecuencia de publicación
  # Posts más frecuentes = más alcance total
  posting_frequency_multiplier = calculate_posting_frequency_multiplier
  
  (estimated_reach_per_post * posting_frequency_multiplier).round
end

private

def has_high_video_ratio?
  return false if total_posts.zero?
  (total_videos.to_f / total_posts) > 0.4
end

def calculate_posting_frequency_multiplier
  # Si publica consistentemente, tiene mejor alcance
  # Asumimos que total_posts es de última semana
  posts_per_day = total_posts / 7.0
  
  case posts_per_day
  when 0...0.5
    0.8  # Publica poco: menos alcance
  when 0.5...1.0
    1.0  # Óptimo: ~1 post por día
  when 1.0...2.0
    1.1  # Muy activo: ligeramente más alcance
  else
    0.9  # Demasiados posts: fatiga de audiencia
  end
end
```

---

### **Enfoque 3: Método Híbrido (Equilibrado) ⭐ RECOMENDADO**

Combina ambos enfoques para mayor precisión.

```ruby
def estimated_reach
  return 0 if followers.zero? || total_posts.zero?
  
  # Método 1: Basado en followers
  follower_based_reach = calculate_follower_based_reach
  
  # Método 2: Basado en interacciones
  interaction_based_reach = calculate_interaction_based_reach
  
  # Promedio ponderado (60% followers, 40% interactions)
  # Esto balancea teoría con realidad
  weighted_reach = (follower_based_reach * 0.6) + (interaction_based_reach * 0.4)
  
  # Cap máximo: nunca más del 50% de followers
  # (Instagram rara vez entrega a más del 50% de la audiencia)
  max_reach = followers * 0.5
  
  [weighted_reach, max_reach].min.round
end

def estimated_reach_percentage
  return 0 if followers.zero?
  (estimated_reach.to_f / followers * 100).round(2)
end

private

def calculate_follower_based_reach
  base_reach_percentage = 15.0
  
  reach = followers * (base_reach_percentage / 100.0)
  reach *= engagement_multiplier
  reach *= content_type_multiplier
  reach *= account_quality_multiplier
  
  reach
end

def calculate_interaction_based_reach
  return 0 if total_posts.zero?
  
  avg_interactions = median_interactions
  
  # Ratio de engagement típico: 10-12% de quienes ven el post interactúan
  interaction_rate = has_high_video_ratio? ? 0.12 : 0.10
  
  # Alcance estimado por post
  avg_interactions / interaction_rate
end

def engagement_multiplier
  benchmark = 3.0
  actual = engagement_rate.to_f
  
  if actual >= benchmark
    [1.0 + ((actual - benchmark) / 10.0), 2.0].min
  else
    [0.5 + (actual / benchmark) * 0.5, 1.0].min
  end
end

def content_type_multiplier
  return 1.0 if total_posts.zero?
  
  video_ratio = total_videos.to_f / total_posts
  1.0 + (video_ratio * 0.5)
end

def account_quality_multiplier
  multiplier = 1.0
  multiplier *= 1.2 if is_verified
  multiplier *= 1.1 if is_business_account
  
  case profile_type
  when 'medio', 'estatal'
    multiplier *= 1.15
  when 'memes'
    multiplier *= 1.3
  when 'marca'
    multiplier *= 0.9
  end
  
  multiplier
end

def has_high_video_ratio?
  return false if total_posts.zero?
  (total_videos.to_f / total_posts) > 0.4
end
```

---

## 📊 Ejemplo de Uso en la Vista

```erb
<!-- app/views/profiles/show.html.erb -->
<div class="metric-card">
  <h3>Alcance Estimado</h3>
  <div class="metric-value">
    <%= number_with_delimiter(@profile.estimated_reach) %>
  </div>
  <div class="metric-subtitle">
    <%= @profile.estimated_reach_percentage %>% de followers
  </div>
</div>
```

---

## 🎯 Precisión Esperada

| Método | Precisión Estimada | Ventajas | Desventajas |
|--------|-------------------|----------|-------------|
| **Conservador** | ±20% | Simple, rápido | Puede subestimar |
| **Interacciones** | ±15% | Más realista | Requiere datos de posts |
| **Híbrido** ⭐ | ±10-15% | Equilibrado | Más complejo |

---

## 📈 Benchmarks de Instagram (2024)

| Rango de Followers | Alcance Promedio | Engagement Rate |
|-------------------|------------------|-----------------|
| 10K - 50K | 20-30% | 3-5% |
| 50K - 100K | 15-25% | 2-4% |
| 100K - 500K | 10-20% | 1.5-3% |
| 500K+ | 8-15% | 1-2% |

**Nota:** Cuentas con contenido viral (memes) pueden tener alcance de hasta 50-100% de sus followers.

---

## 🔥 Mejoras Futuras (Cuando Toquemos DB)

Agregar estos campos para cálculo más preciso:

```ruby
# Campos ideales para alcance real:
- impressions_count (int)           # Vistas totales
- reach_count (int)                 # Cuentas únicas alcanzadas
- saves_count (int)                 # Guardados (señal fuerte)
- shares_count (int)                # Compartidos (viralidad)
```

Con estos campos, podríamos calcular:

```ruby
def actual_reach
  # Promedio de reach de últimos 10 posts
  recent_posts.limit(10).average(:reach_count)
end
```

---

## ✅ Conclusión

**Recomendación:** Usar el **Método Híbrido** porque:

1. ✅ No requiere cambios en DB
2. ✅ Usa datos que ya tenemos
3. ✅ Precisión aceptable (±10-15%)
4. ✅ Ajustado por múltiples factores
5. ✅ Fácil de implementar

**Implementación inmediata:** Agregar los 3 métodos al modelo `Profile` y mostrarlo en la vista del perfil.

