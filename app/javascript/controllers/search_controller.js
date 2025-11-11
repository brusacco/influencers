import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.hideTimeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
  }

  showResults() {
    // Only show if there's content
    if (this.resultsTarget.children[0]?.children.length > 0) {
      this.resultsTarget.classList.remove('hidden')
    }
  }

  hideResults() {
    this.resultsTarget.classList.add('hidden')
  }

  hideResultsDelayed() {
    // Delay hiding to allow clicking on results
    this.hideTimeout = setTimeout(() => {
      this.hideResults()
    }, 200)
  }

  preventBlur(event) {
    // Prevent the input from losing focus when clicking results
    event.preventDefault()
  }

  search() {
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    const query = this.inputTarget.value.trim()

    // If query is empty, clear and hide results
    if (query.length === 0) {
      this.resultsTarget.children[0].innerHTML = ''
      this.hideResults()
      return
    }

    // Wait 300ms after user stops typing before searching
    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const url = `/api/v1/profiles/search?q=${encodeURIComponent(query)}`
      const response = await fetch(url)
      const data = await response.json()

      this.displayResults(data.profiles)
    } catch (error) {
      console.error('Search error:', error)
      this.resultsTarget.children[0].innerHTML = `
        <div class="px-4 py-6 text-center text-gray-500">
          <p class="text-sm font-medium text-red-600">Error al buscar</p>
          <p class="text-xs text-gray-400 mt-1">Por favor, intenta de nuevo</p>
        </div>
      `
      this.showResults()
    }
  }

  displayResults(profiles) {
    const containerDiv = this.resultsTarget.children[0]
    
    if (profiles.length === 0) {
      containerDiv.innerHTML = `
        <div class="px-4 py-6 text-center text-gray-500">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-10 h-10 mx-auto mb-2 text-gray-400">
            <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
          </svg>
          <p class="text-sm font-medium">No se encontraron resultados</p>
          <p class="text-xs text-gray-400 mt-1">Intenta con otro término</p>
        </div>
      `
      this.hideResults()
      return
    }

    const resultsHtml = profiles.map(profile => `
      <a href="${profile.profile_url}" 
         class="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 transition-colors group">
        <div class="relative flex-shrink-0">
          ${profile.avatar_url 
            ? `<img src="${profile.avatar_url}" 
                    alt="${profile.username}" 
                    class="w-10 h-10 rounded-full object-cover ring-2 ring-gray-200 group-hover:ring-blue-400 transition-all">`
            : `<div class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center ring-2 ring-gray-200 group-hover:ring-blue-400 transition-all">
                <span class="text-white font-bold">${profile.username.charAt(0).toUpperCase()}</span>
               </div>`
          }
        </div>
        <div class="flex-1 min-w-0">
          <div class="font-medium text-gray-900 truncate group-hover:text-blue-600 transition-colors text-sm">
            ${profile.full_name || profile.username}
          </div>
          <div class="text-xs text-gray-500 truncate">
            @${profile.username}
          </div>
        </div>
        <div class="flex-shrink-0 text-right">
          <div class="text-sm font-semibold text-gray-900">
            ${this.formatNumber(profile.followers)}
          </div>
          <div class="text-xs text-gray-400">seguidores</div>
        </div>
      </a>
    `).join('')

    containerDiv.innerHTML = resultsHtml
    this.showResults()
  }

  formatNumber(num) {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(1).replace(/\.0$/, '') + 'M'
    }
    if (num >= 1000) {
      return (num / 1000).toFixed(1).replace(/\.0$/, '') + 'K'
    }
    return num.toString()
  }
}

