# frozen_string_literal: true

require "rails_helper"

RSpec.describe RefreshIersDataJob, type: :job do
  it "clears loaded data when the update succeeds" do
    result = IERS::UpdateResult.new(
      updated_files: %i[finals leap_seconds],
      errors: {}
    )
    allow(IERS::Data).to receive(:update!).and_return(result)
    allow(IERS::Data).to receive(:clear_loaded!)

    described_class.perform_now

    expect(IERS::Data).to have_received(:clear_loaded!)
  end

  it "raises when a source fails to download so the failure is visible" do
    error = IERS::DownloadError.new("connection refused")
    result = IERS::UpdateResult.new(
      updated_files: [:leap_seconds],
      errors: {finals: error}
    )
    allow(IERS::Data).to receive(:update!).and_return(result)
    allow(IERS::Data).to receive(:clear_loaded!)

    expect {
      described_class.new.perform
    }.to raise_error(
      described_class::RefreshError,
      /finals: connection refused/
    )
    expect(IERS::Data).not_to have_received(:clear_loaded!)
  end
end
