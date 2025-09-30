# frozen_string_literal: true

require "rails_helper"

RSpec.describe HijriCalendar do
  describe ".date_for" do
    it "converts real Gregorian dates to Islamic dates" do
      # January 1, 2024 CE = Jumada al-Akhirah 19, 1445 AH
      time = Time.new(2024, 1, 1)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1445, 6, 19])
    end

    it "converts another real date correctly" do
      # November 23, 2023 CE = Jumada al-Awwal 9, 1445 AH
      time = Time.new(2023, 11, 23)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1445, 5, 9])
    end

    it "converts March 14, 1991 correctly" do
      # March 14, 1991 CE = Sha'ban 28, 1411 AH
      time = Time.new(1991, 3, 14)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1411, 8, 28])
    end

    it "converts March 10, 1990 correctly (hijridate test case)" do
      # March 10, 1990 CE = Sha'ban 13, 1410 AH
      time = Time.new(1990, 3, 10)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1410, 8, 13])
    end

    it "converts epoch date correctly" do
      # July 16, 622 CE = Muharram 1, 1 AH (Islamic epoch)
      time = Time.new(622, 7, 16)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1, 1, 1])
    end

    it "converts another modern date" do
      # December 31, 2023 CE = Jumada al-Akhirah 18, 1445 AH
      time = Time.new(2023, 12, 31)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1445, 6, 18])
    end

    it "converts December 7, 2014 correctly" do
      # December 7, 2014 CE = Safar 15, 1436 AH
      time = Time.new(2014, 12, 7)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1436, 2, 15])
    end

    it "converts December 31, 2017 correctly" do
      # December 31, 2017 CE = Rabi' al-Thani 13, 1439 AH
      time = Time.new(2017, 12, 31)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1439, 4, 13])
    end

    it "converts December 29, 2008 correctly" do
      # December 29, 2008 CE = Muharram 1, 1430 AH
      time = Time.new(2008, 12, 29)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1430, 1, 1])
    end

    it "converts January 1, 2000 correctly" do
      # January 1, 2000 CE = Ramadan 24, 1420 AH
      time = Time.new(2000, 1, 1)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1420, 9, 24])
    end

    it "converts July 20, 1969 correctly (moon landing)" do
      # July 20, 1969 CE = Jumada al-Awwal 6, 1389 AH
      time = Time.new(1969, 7, 20)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1389, 5, 6])
    end

    it "converts September 11, 2001 correctly" do
      # September 11, 2001 CE = Jumada al-Akhirah 23, 1422 AH
      time = Time.new(2001, 9, 11)
      islamic_date = HijriCalendar.date_for(time)

      expect(islamic_date).to eq([1422, 6, 23])
    end
  end

  describe ".formatted_date_for" do
    it "formats real dates correctly" do
      # January 1, 2024 CE = Jumada al-Akhirah 19, 1445 AH
      time = Time.new(2024, 1, 1)
      formatted_date = HijriCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("19 Jumada al-Thani 1445 AH")
    end

    it "formats November 2023 correctly" do
      # November 23, 2023 CE = Jumada al-Awwal 9, 1445 AH
      time = Time.new(2023, 11, 23)
      formatted_date = HijriCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("9 Jumada al-Awwal 1445 AH")
    end

    it "formats December 2014 correctly" do
      # December 7, 2014 CE = Safar 15, 1436 AH
      time = Time.new(2014, 12, 7)
      formatted_date = HijriCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("15 Safar 1436 AH")
    end

    it "formats epoch date correctly" do
      # July 16, 622 CE = Muharram 1, 1 AH
      time = Time.new(622, 7, 16)
      formatted_date = HijriCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("1 Muharram 1 AH")
    end

    it "formats Ramadan month correctly" do
      # January 1, 2000 CE = Ramadan 24, 1420 AH
      time = Time.new(2000, 1, 1)
      formatted_date = HijriCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("24 Ramadan 1420 AH")
    end

    it "formats Muharram month correctly" do
      # December 29, 2008 CE = Muharram 1, 1430 AH
      time = Time.new(2008, 12, 29)
      formatted_date = HijriCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("1 Muharram 1430 AH")
    end
  end
end
