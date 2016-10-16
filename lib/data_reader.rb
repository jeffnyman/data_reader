require "data_reader/version"
require "yaml"
require "erb"

module DataReader
  def data_path=(path)
    @data_path = path
  end

  def data_path
    return @data_path if @data_path
    return default_data_path if respond_to? :default_data_path
    nil
  end

  def load(file_list)
    files = file_list.include?(',') ? file_list.split(',') : [file_list]
    @data_source = files.inject({}) do |data, file|
      data.merge!(YAML.load(
                    ERB.new(File.read("#{data_path}/#{file}")).result(binding)
      ))
    end
  end

  def include_data(filename)
    ERB.new(IO.read("#{data_path}/#{filename}")).result
  end
end
