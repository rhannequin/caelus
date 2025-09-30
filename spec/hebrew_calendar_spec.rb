# frozen_string_literal: true

require "rails_helper"

RSpec.describe HebrewCalendar do
  describe "#date_for" do
    it "converts 2009-08-21 correctly" do
      time = Time.new(2009, 8, 21)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5769, 6, 1])
    end

    it "converts 2009-09-30 correctly" do
      time = Time.new(2009, 9, 30)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5770, 7, 12])
    end

    it "converts 2009-11-13 correctly" do
      time = Time.new(2009, 11, 13)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5770, 8, 26])
    end

    it "converts 2010-01-21 correctly" do
      time = Time.new(2010, 1, 21)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5770, 11, 6])
    end

    it "converts 2010-05-26 correctly" do
      time = Time.new(2010, 5, 26)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5770, 3, 13])
    end

    it "converts 2013-11-17 correctly" do
      time = Time.new(2013, 11, 17)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5774, 9, 14])
    end

    it "converts 2014-03-12 correctly" do
      time = Time.new(2014, 3, 12)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5774, 13, 10])
    end

    it "converts 2014-06-10 correctly" do
      time = Time.new(2014, 6, 10)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5774, 3, 12])
    end

    it "converts 2016-02-10 correctly" do
      time = Time.new(2016, 2, 10)

      hebrew_date = HebrewCalendar.date_for(time)

      expect(hebrew_date).to eq([5776, 12, 1])
    end
  end

  describe "#formatted_date_for" do
    it "formats 2009-08-21 correctly" do
      time = Time.new(2009, 8, 21)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("1 Elul 5769")
    end

    it "formats 2009-09-30 correctly" do
      time = Time.new(2009, 9, 30)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("12 Tishrei 5770")
    end

    it "formats 2009-11-13 correctly" do
      time = Time.new(2009, 11, 13)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("26 Cheshvan 5770")
    end

    it "formats 2010-01-21 correctly" do
      time = Time.new(2010, 1, 21)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("6 Shevat 5770")
    end

    it "formats 2010-05-26 correctly" do
      time = Time.new(2010, 5, 26)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("13 Sivan 5770")
    end

    it "formats 2013-11-17 correctly" do
      time = Time.new(2013, 11, 17)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("14 Kislev 5774")
    end

    it "formats 2014-03-12 correctly" do
      time = Time.new(2014, 3, 12)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("10 Adar II 5774")
    end

    it "formats 2014-06-10 correctly" do
      time = Time.new(2014, 6, 10)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("12 Sivan 5774")
    end

    it "formats 2016-02-10 correctly" do
      time = Time.new(2016, 2, 10)

      formatted_date = HebrewCalendar.formatted_date_for(time)

      expect(formatted_date).to eq("1 Adar 5776")
    end
  end
end
