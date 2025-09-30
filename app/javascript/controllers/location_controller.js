import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat", "lng", "utc", "detectBtn"]

  connect() {
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener("keydown", this.boundCloseOnEscape)

    if (this.hasDetectBtnTarget) {
      this.originalButtonText = this.detectBtnTarget.textContent
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundCloseOnEscape)
    this.stopLoadingAnimation()
  }

  detect(event) {
    event.preventDefault()

    if ("geolocation" in navigator) {
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
          this.setTimezoneFromLocation()
          this.setDefaultState()
        },
        (error) => {
          this.setErrorState()
        },
        options
      )
    }
  }

  setDetectingState() {
    if (this.hasDetectBtnTarget) {
      this.detectBtnTarget.disabled = true
      this.detectBtnTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.startLoadingAnimation()
    }
  }

  setDefaultState() {
    if (this.hasDetectBtnTarget) {
      this.stopLoadingAnimation()
      this.detectBtnTarget.textContent = this.originalButtonText
      this.detectBtnTarget.disabled = false
      this.detectBtnTarget.classList.remove(
        "opacity-50",
        "cursor-not-allowed",
        "bg-red-500",
        "hover:bg-red-600"
      )
      this.detectBtnTarget.classList.add("bg-primary", "hover:bg-primary/90")
    }
  }

  setErrorState() {
    if (this.hasDetectBtnTarget) {
      this.stopLoadingAnimation()
      this.detectBtnTarget.textContent = "Location unavailable"
      this.detectBtnTarget.disabled = true
      this.detectBtnTarget.classList.remove("bg-primary", "hover:bg-primary/90")
      this.detectBtnTarget.classList.add(
        "cursor-not-allowed",
        "bg-gray-200",
        "dark:bg-gray-700",
        "text-gray-500",
        "dark:text-gray-400",
        "border",
        "border-gray-300",
        "dark:border-gray-600"
      )
    }
  }

  setTimezoneFromLocation() {
    if (!this.hasUtcTarget) return

    const now = new Date()
    const utcOffsetMinutes = -now.getTimezoneOffset()
    const hours = Math.floor(Math.abs(utcOffsetMinutes) / 60.0)
    const minutes = Math.abs(utcOffsetMinutes) % 60

    // Round minutes to nearest 15-minute interval
    const roundedMinutes = Math.round(minutes / 15.0) * 15
    const adjustedHours = hours + Math.floor(roundedMinutes / 60.0)
    const finalMinutes = roundedMinutes % 60

    // Ensure we don't exceed 12 hours
    const clampedHours = Math.min(adjustedHours, 12)

    const sign = utcOffsetMinutes >= 0 ? "+" : "-"
    const formattedHours = clampedHours.toString().padStart(2, "0")
    const formattedMinutes = finalMinutes.toString().padStart(2, "0")

    const timezoneValue = `${sign}${formattedHours}:${formattedMinutes}`

    const select = this.utcTarget
    for (let option of select.options) {
      if (option.value === timezoneValue) {
        option.selected = true
        break
      }
    }
  }

  close() {
    const modalFrame = document.getElementById("location_modal")
    if (modalFrame) {
      modalFrame.innerHTML = ""
    }
  }

  cancel(event) {
    event.preventDefault()
    this.close()
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  startLoadingAnimation() {
    if (!this.hasDetectBtnTarget) return

    let dotCount = 0
    this.loadingInterval = setInterval(() => {
      const text = dotCount === 0 ? "\u00A0" : ".".repeat(dotCount)
      this.detectBtnTarget.textContent = text
      dotCount = (dotCount + 1) % 4
    }, 200)
  }

  stopLoadingAnimation() {
    if (this.loadingInterval) {
      clearInterval(this.loadingInterval)
      this.loadingInterval = null
    }
  }
}
