import { Controller } from '@hotwired/stimulus'

// Base controller for turbo-frame modals. Closes the modal by clearing its
// enclosing turbo-frame and on the Escape key. Subclasses that override
// connect/disconnect must call super.
export default class extends Controller {
  connect () {
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.boundCloseOnEscape)
  }

  disconnect () {
    document.removeEventListener('keydown', this.boundCloseOnEscape)
  }

  close () {
    const modalFrame = this.element.closest('turbo-frame')
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
}
