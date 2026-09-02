# frozen_string_literal: true

module ApplicationHelper
  def canonical_url
    return content_for(:canonical) if content_for?(:canonical)

    request.base_url + request.path
  end
end
