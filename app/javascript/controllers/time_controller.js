import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['timeField']
  static values = { timezone: String }
  connect () {
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.boundCloseOnEscape)
  }

  disconnect () {
    document.removeEventListener('keydown', this.boundCloseOnEscape)
  }

  close () {
    const modalFrame = document.getElementById('time_modal')
    if (modalFrame) {
      modalFrame.innerHTML = ''
    }
  }

  cancel (event) {
    event.preventDefault()
    this.close()
  }

  closeOnEscape (event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  setCurrentTime (event) {
    event.preventDefault()
    const now = new Date()
    const timezone = this.timezoneValue || 'UTC'

    const formattedDateTime = now.toLocaleString('sv-SE', {
      timeZone: timezone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    }).replace(' ', 'T')

    this.timeFieldTarget.value = formattedDateTime
  }
}
