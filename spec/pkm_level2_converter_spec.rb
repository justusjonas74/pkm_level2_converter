# frozen_string_literal: true

RSpec.describe PkmLevel2Converter do
  let(:testdata) { PkmLevel2Converter::Converter.new('DLKM_6065_G210801_0000_E1_1_1.3_RBO.xml') }

  it 'has a version number' do
    expect(PkmLevel2Converter::VERSION).not_to be nil
  end
  describe '#filename' do
    it 'should has an instance variable filename' do
      expect(testdata.filename).to eq('DLKM_6065_G210801_0000_E1_1_1.3_RBO.xml')
    end
  end

  describe '#convertFileName()' do
    it 'should return an valid level 2 filename' do
      expect(testdata.convertFileName).to eq('DLKM_38833_G210801_0000_E1_1_1.3_RBO.xml')
    end
  end
end
