# frozen_string_literal: true

class CookieConsentController < ApplicationController
  def create
    cookies.signed[:cookie_consent] =
      {value: "true", expires: 1.year.from_now}

    redirect_back(fallback_location: root_path)
  end

  def destroy
    cookies.delete(:cookie_consent)
    cookies.delete(:latitude)
    cookies.delete(:longitude)
    cookies.delete(:utc_offset)

    cookies.signed[:cookie_consent] =
      {value: "false", expires: 1.year.from_now}

    redirect_back(fallback_location: root_path)
  end
end
