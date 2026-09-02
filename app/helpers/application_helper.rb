# frozen_string_literal: true

module ApplicationHelper
  def canonical_url
    return content_for(:canonical) if content_for?(:canonical)

    request.base_url + request.path
  end

  def document_title
    return t("title") unless content_for?(:title)

    safe_join([content_for(:title), t("title")], " • ")
  end

  def site_heading
    return t("title") unless content_for?(:heading)

    safe_join([t("title"), content_for(:heading)], " • ")
  end
end
