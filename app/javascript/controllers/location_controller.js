import Modal from 'controllers/modal'

export default class extends Modal {
  static targets = ['lat', 'lng', 'detectBtn', 'timeZone']

  connect () {
    super.connect()

    if (this.hasDetectBtnTarget) {
      this.originalButtonText = this.detectBtnTarget.textContent
    }
  }

  disconnect () {
    super.disconnect()
    this.stopLoadingAnimation()
  }

  detect (event) {
    event.preventDefault()

    if ('geolocation' in navigator) {
      this.setDetectingState()

      const options = {
        enableHighAccuracy: true,
        timeout: 7000,
        maximumAge: 60000
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          if (this.hasLatTarget && this.hasLngTarget) {
            this.latTarget.value = position.coords.latitude.toFixed(4)
            this.lngTarget.value = position.coords.longitude.toFixed(4)
          }
          this.setUserTimeZone()
          this.setDefaultState()
        },
        (_error) => {
          this.setErrorState()
        },
        options
      )
    }
  }

  setDetectingState () {
    if (this.hasDetectBtnTarget) {
      this.detectBtnTarget.disabled = true
      this.detectBtnTarget.classList.add('opacity-50', 'cursor-not-allowed')
      this.startLoadingAnimation()
    }
  }

  setDefaultState () {
    if (this.hasDetectBtnTarget) {
      this.stopLoadingAnimation()
      this.detectBtnTarget.textContent = this.originalButtonText
      this.detectBtnTarget.disabled = false
      this.detectBtnTarget.classList.remove(
        'opacity-50',
        'cursor-not-allowed',
        'bg-red-500',
        'hover:bg-red-600'
      )
      this.detectBtnTarget.classList.add('bg-primary', 'hover:bg-primary/90')
    }
  }

  setErrorState () {
    if (this.hasDetectBtnTarget) {
      this.stopLoadingAnimation()
      this.detectBtnTarget.textContent = 'Location unavailable'
      this.detectBtnTarget.disabled = true
      this.detectBtnTarget.classList.remove('bg-primary', 'hover:bg-primary/90')
      this.detectBtnTarget.classList.add(
        'cursor-not-allowed',
        'bg-gray-200',
        'dark:bg-gray-700',
        'text-gray-500',
        'dark:text-gray-400',
        'border',
        'border-gray-300',
        'dark:border-gray-600'
      )
    }
  }

  setUserTimeZone () {
    if (this.hasTimeZoneTarget) {
      try {
        this.timeZoneTarget.value = Intl
          .DateTimeFormat()
          .resolvedOptions()
          .timeZone
      } catch (_error) {}
    }
  }

  startLoadingAnimation () {
    if (!this.hasDetectBtnTarget) return

    let dotCount = 0
    this.loadingInterval = setInterval(() => {
      const text = dotCount === 0 ? '\u00A0' : '.'.repeat(dotCount)
      this.detectBtnTarget.textContent = text
      dotCount = (dotCount + 1) % 4
    }, 200)
  }

  stopLoadingAnimation () {
    if (this.loadingInterval) {
      clearInterval(this.loadingInterval)
      this.loadingInterval = null
    }
  }
}
