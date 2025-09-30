# frozen_string_literal: true

module MoonInterferenceHelper
  def interference_color(interference)
    case interference
    when :none
      "text-green-600 dark:text-green-400"
    when :low
      "text-lime-600 dark:text-lime-400"
    when :moderate
      "text-yellow-600 dark:text-yellow-400"
    when :high
      "text-orange-600 dark:text-orange-400"
    when :extreme, :full
      "text-red-600 dark:text-red-400"
    else
      "text-gray-600 dark:text-gray-400"
    end
  end
end
