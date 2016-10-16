require "spec_helper"

module TestModule
  extend DataReader

  def self.data
    @data_source
  end

  def self.default_data_path
    'default_test_path'
  end
end

RSpec.describe DataReader do
  it "has a version number" do
    expect(DataReader::VERSION).not_to be nil
  end

  context 'when configuring the data directory' do
    before(:each) do
      TestModule.data_path = nil
    end

    it 'stores a data directory' do
      TestModule.data_path = 'test_path'
      expect(TestModule.data_path).to eq 'test_path'
    end

    it 'defaults to a directory specified by the containing class' do
      expect(TestModule.data_path).to eq 'default_test_path'
    end
  end

  context 'when including data files' do
    before(:each) do
      TestModule.data_path = File.expand_path('data', File.dirname(__FILE__))
    end

    it 'loads data from the included file' do
      TestModule.load 'example.yml'
      expect(TestModule.data['from_included']['testing']).to eq('zzyzx')
    end
  end

  context 'when loading multiple data files' do
    before(:each) do
      TestModule.data_path = File.expand_path('data', File.dirname(__FILE__))
    end

    it 'merges the data from all the files' do
      TestModule.load 'data_001.yml,data_002.yml,data_003.yml'

      3.times do |file|
        TestModule.data["key_from_data_00#{file}"] == "value_from_data_00#{file}"
      end
    end
  end
end
