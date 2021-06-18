# frozen_string_literal: true

RSpec.describe PkmLevel2Converter do
  it "has a version number" do
    expect(PkmLevel2Converter::VERSION).not_to be nil
  end

  it "should has an instance variable filename" do
    expect(PkmLevel2Converter.Converter.new("hello").filename).to eq("hello")
  end
end
