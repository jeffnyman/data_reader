module TestModule
  extend DataReader

  def self.data
    @data_contents
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
      expect(TestModule.data_contents).not_to be_nil
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
