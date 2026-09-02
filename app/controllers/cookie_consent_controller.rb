# frozen_string_literal: true

class CookieConsentController < ApplicationController
  self.noindex = true

  def new
    render layout: false
  end

  def create
    cookies.signed[:cookie_consent] =
      {value: "true", expires: 1.year.from_now}

    track_consent("accepted")

    redirect_back(fallback_location: root_path)
  end

  def destroy
    cookies.delete(:cookie_consent)
    cookies.delete(:latitude)
    cookies.delete(:longitude)
    cookies.delete(:time_zone)
    cookies.delete(:time)

    cookies.signed[:cookie_consent] =
      {value: "false", expires: 1.year.from_now}

    track_consent("declined")

    redirect_back(fallback_location: root_path)
  end
end
