# frozen_string_literal: true

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.script_src :self
    policy.style_src :self, :unsafe_inline
    policy.img_src :self, :data
    policy.font_src :self
    policy.connect_src :self
    policy.form_action :self
    policy.frame_ancestors :none
    policy.object_src :none
    policy.base_uri :self

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline
  # styles.
  config.content_security_policy_nonce_generator =
    ->(request) { SecureRandom.base64(16) }

  config.content_security_policy_nonce_directives = %w[script-src]

  # Start with report-only mode to monitor for violations
  # config.content_security_policy_report_only = true
end
