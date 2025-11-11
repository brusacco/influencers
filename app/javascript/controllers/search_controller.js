import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.hideTimeout = null
    this.currentPage = 1
    this.hasMore = true
    this.isLoading = false
    this.currentQuery = ''
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
      this.currentPage = 1
      this.hasMore = true
      this.currentQuery = ''
      return
    }

    // Reset pagination if query changed
    if (query !== this.currentQuery) {
      this.currentPage = 1
      this.hasMore = true
      this.currentQuery = query
    }

    // Wait 300ms after user stops typing before searching
    this.timeout = setTimeout(() => {
      this.performSearch(query, true) // true = replace results
    }, 300)
  }

  // Handle scroll event to load more results
  handleScroll(event) {
    const container = event.target
    const scrollTop = container.scrollTop
    const scrollHeight = container.scrollHeight
    const clientHeight = container.clientHeight
    
    // Check if scrolled near bottom (within 50px)
    if (scrollHeight - scrollTop - clientHeight < 50) {
      this.loadMore()
    }
  }

  loadMore() {
    // Don't load if already loading, no more results, or no query
    if (this.isLoading || !this.hasMore || !this.currentQuery) {
      return
    }

    this.currentPage++
    this.performSearch(this.currentQuery, false) // false = append results
  }

  async performSearch(query, replace = true) {
    if (this.isLoading) return
    
    this.isLoading = true
    
    try {
      const url = `/api/v1/profiles/search?q=${encodeURIComponent(query)}&page=${this.currentPage}`
      const response = await fetch(url)
      const data = await response.json()

      this.hasMore = data.has_more
      this.displayResults(data.profiles, replace)
    } catch (error) {
      console.error('Search error:', error)
      if (replace) {
        this.resultsTarget.children[0].innerHTML = `
          <div class="px-4 py-6 text-center text-gray-500">
            <p class="text-sm font-medium text-red-600">Error al buscar</p>
            <p class="text-xs text-gray-400 mt-1">Por favor, intenta de nuevo</p>
          </div>
        `
      }
      this.showResults()
    } finally {
      this.isLoading = false
    }
  }

  displayResults(profiles, replace = true) {
    const containerDiv = this.resultsTarget.children[0]
    
    if (profiles.length === 0 && replace) {
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
         class="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 transition-colors group border-b border-gray-100 last:border-0">
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

    if (replace) {
      containerDiv.innerHTML = resultsHtml
    } else {
      // Append results
      containerDiv.insertAdjacentHTML('beforeend', resultsHtml)
    }

    // Add loading indicator if there are more results
    if (this.hasMore) {
      const loadingHtml = `
        <div class="loading-indicator px-4 py-3 text-center text-gray-500">
          <div class="inline-flex items-center gap-2">
            <svg class="animate-spin h-4 w-4 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span class="text-xs">Scroll para cargar más...</span>
          </div>
        </div>
      `
      // Remove old loading indicator if exists
      const oldLoading = containerDiv.querySelector('.loading-indicator')
      if (oldLoading) {
        oldLoading.remove()
      }
      containerDiv.insertAdjacentHTML('beforeend', loadingHtml)
    } else {
      // Remove loading indicator if no more results
      const loadingIndicator = containerDiv.querySelector('.loading-indicator')
      if (loadingIndicator) {
        loadingIndicator.remove()
      }
    }

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

