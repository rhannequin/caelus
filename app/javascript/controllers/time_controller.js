import Modal from 'controllers/modal'

export default class extends Modal {
  static targets = ['timeField']
  static values = { timezone: String }

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
