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

    it 'loads data from included file' do
      TestModule.load 'with_includes.yml'
      expect(TestModule.data['include1']['keyn1']).to eql('Value 1')
    end

    it 'loads data from a chained included file' do
      TestModule.load 'with_includes.yml'
      expect(TestModule.data['include_chain1']['key_chain_1']).to eql('chain 1')
    end

    it 'loads data from an _include_ directive in a file' do
      TestModule.load 'with_includes.yml'
      expect(TestModule.data['include_nested']['keyn_1']).to eql('Value nested 1')
    end

    it 'loads data from a chained _include_ directive' do
      TestModule.load 'with_includes.yml'
      expect(TestModule.data['second_chain1']['skey_chain_1']).to eql('schain 1')
    end

    it 'loads data from a nested _include_ directive' do
      TestModule.load 'with_includes.yml'
      expect(
        TestModule.data['include_nested']['nested_key']['nested_value']['deep_nested_key']
      ).to eql('deep nested value')
    end
  end
end

=begin
RSpec.describe DataReader do
  context 'when including data files' do


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

  context 'when chaining include files' do
    before(:each) do
      TestModule.data_path = File.expand_path('data', File.dirname(__FILE__))
    end

    it 'loads data from the chained file that was included via _include_' do
      TestModule.load 'use_includes.yml'
      expect(TestModule.data['from_chained']['key_from_chained']).to eq('value_from_chained')
    end
  end
end
=end
