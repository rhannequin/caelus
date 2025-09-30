import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["darkIcon", "lightIcon"]

  connect() {
    this.restoreTheme()
    this.updateIconVisibility()
  }

  toggleTheme() {
    const isDark = document.documentElement.classList.toggle("dark")
    this.saveTheme(isDark)
    this.updateIconVisibility()
  }

  saveTheme(isDark) {
    try {
      localStorage.setItem("theme", isDark ? "dark" : "light")
    } catch (e) {}
  }

  restoreTheme() {
    try {
      const savedTheme = localStorage.getItem("theme")
      if (savedTheme === "dark") {
        document.documentElement.classList.add("dark")
      } else if (savedTheme === "light") {
        document.documentElement.classList.remove("dark")
      } else {
        this.checkSystemPreference()
      }
    } catch (e) {}
  }

  checkSystemPreference() {
    if (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    ) {
      document.documentElement.classList.add("dark")
    }
  }

  updateIconVisibility() {
    const isDark = document.documentElement.classList.contains("dark")
    this.darkIconTarget.classList.toggle("hidden", isDark)
    this.lightIconTarget.classList.toggle("hidden", !isDark)
  }
}
