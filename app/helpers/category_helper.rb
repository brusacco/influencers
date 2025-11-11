# frozen_string_literal: true

module CategoryHelper
  def category_hero_colors(category)
    case category.to_s.downcase
    when 'hombre'
      {
        gradient: 'from-blue-900 via-cyan-900 to-teal-900',
        badge_icon: 'text-blue-300',
        text_accent: 'text-blue-100'
      }
    when 'mujer'
      {
        gradient: 'from-pink-900 via-rose-900 to-red-900',
        badge_icon: 'text-pink-300',
        text_accent: 'text-pink-100'
      }
    when 'marca'
      {
        gradient: 'from-purple-900 via-violet-900 to-indigo-900',
        badge_icon: 'text-purple-300',
        text_accent: 'text-purple-100'
      }
    when 'medio'
      {
        gradient: 'from-orange-900 via-amber-900 to-yellow-900',
        badge_icon: 'text-orange-300',
        text_accent: 'text-orange-100'
      }
    when 'estatal'
      {
        gradient: 'from-green-900 via-emerald-900 to-teal-900',
        badge_icon: 'text-green-300',
        text_accent: 'text-green-100'
      }
    when 'memes'
      {
        gradient: 'from-yellow-900 via-orange-900 to-red-900',
        badge_icon: 'text-yellow-300',
        text_accent: 'text-yellow-100'
      }
    when 'programa'
      {
        gradient: 'from-indigo-900 via-blue-900 to-cyan-900',
        badge_icon: 'text-indigo-300',
        text_accent: 'text-indigo-100'
      }
    else
      {
        gradient: 'from-slate-900 via-gray-900 to-zinc-900',
        badge_icon: 'text-gray-300',
        text_accent: 'text-gray-100'
      }
    end
  end
end
