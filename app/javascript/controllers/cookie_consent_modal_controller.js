import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.boundCloseOnEscape)
  }

  disconnect () {
    document.removeEventListener('keydown', this.boundCloseOnEscape)
  }

  close () {
    const modalFrame = document.getElementById('cookie_consent_modal')
    if (modalFrame) {
      modalFrame.innerHTML = ''
    }
  }

  closeOnEscape (event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}
