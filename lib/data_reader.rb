require "data_reader/version"
require "pathname"
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

  def data_source
    return @data_source if @data_source

    nil
  end

  def load(file_list)
    files = file_list.include?(',') ? file_list.split(',') : [file_list]
    files = files.collect(&:strip)

    @data_source = files.inject({}) do |all_data, file|
      data = include_key(::YAML.safe_load(include_data(file)))
      all_data.merge!(data) if data
    end
  end

  def include_data(file)
    filename = Pathname.new(file).absolute? ? file : "#{@data_path}/#{file}"
    ERB.new(IO.read(filename)).result(binding) if File.exist?(filename)
  end

  private

  def include_key(data)
    include_data = {}

    if data.key?('_include_')
      [data['_include_']].flatten.each do |file_path|
        include_data.merge!(load(file_path))
      end
    end

    data.delete('_include_')
    data.merge!(include_data)

    data.each do |key, value|
      data[key] = include_key(value) if value.is_a?(Hash)
    end

    data
  end
end
