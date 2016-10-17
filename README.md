# DataReader

[![Gem Version](https://badge.fury.io/rb/data_reader.svg)](http://badge.fury.io/rb/data_reader)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jnyman/data_reader/blob/master/LICENSE.txt)

The DataReader gem is used to provide a standard mechanism for providing a YAML data source and loading data from it. DataReader is mainly used as a support gem that can be included by other libraries that need this functionality.

## Installation

To get the latest stable release, add this line to your application's Gemfile:

```ruby
gem 'data_reader'
```

And then include it in your bundle:

    $ bundle

You can also install DataReader just as you would any other gem:

    $ gem install data_reader

## Usage

### Including DataReader

You can include the DataReader in a class or module.

```ruby
require "data_reader"

class Testing
  include DataReader
end
```

DataReader does not set defaults for anything. It does hold a `data_path` that you set. It holds a `data_source` that is populated with the result of a file load.

With the above class in place, you could do this:

```ruby
test = Testing.new

test.data_path = 'data'

puts test.data_path

test.load 'default.yml'

puts test.data_source
```

Here you are setting the `data_path` to a directory called `data`. The `puts` statement after that simply confirms that this was set. You then call the `load` method for a YAML file that is in that directory. The `puts` call for the `data_source` will show you the contents of the YAML.

You could have specified the `data_path` as part of the class instead, like this:

```ruby
class Testing
  include DataReader

  def data_path
    'data'
  end
end
```

Then you don't have to set the path specifically.

You can load multiple YAML files. The `load` method takes a list of comma separated names of files that are in that same directory.

```ruby
load 'users.yml, accounts.yml, billing.yml'
```

When loading in multiple files, the `data_source` will hold the contents of all the files in the list.

### Extending DataReader

You can also extend, rather than include, DataReader. This means you deal with the class rather than an instance of it. For example:

```ruby
require "data_reader"

class Testing
  extend DataReader
end

Testing.data_path = 'data'

puts Testing.data_path

Testing.load 'default.yml'

puts Testing.data_source
```

Note that you can provide methods as you did in the include class, but make sure they are defined on `self`. For example:

```ruby
class Testing
  extend DataReader

  def self.data_path
    'data'
  end
end
```

### Default Path

You can, at any time, set a data path. When you do, any calls to `load` will use that data path. However, you may want to make sure that a default data path is always available should a data path not have been specifically set. You can do that as follows:

```ruby
class Testing
  include DataReader

  def default_data_path
    'data'
  end
end
```

Remember to add a `self` to the method call if you are extending DataReader.

Keep in mind that DataReader will always favor whatever it has stored in `data_path`. The `default_data_path` can be used for a fallback.

### Parameterizing Files

You can set environment variables in YAML files. To do this you have to use ERB, like this:

```yaml
<%= ENV['XYZZY'] %>
```

To handle this, DataReader parses any values with ERB before it parses the YAML itself.

The support for ERB allows for custom calls. One that is included with DataReader is `include_data`, which can be used like this:

```yaml
<%= include_data("my_data.yml") %>
```

If the above line was in a file called `default.yml` and you used the `load 'default.yml'` command, then, because of the call to `include_data` you would end up with the data from both files.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec:all` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/jnyman/data_reader](https://github.com/jnyman/data_reader). The testing ecosystem of Ruby is very large and this project is intended to be a welcoming arena for collaboration on yet another testing tool. As such, contributors are very much welcome but are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

To contribute to DataReader:

1. [Fork the project](http://gun.io/blog/how-to-github-fork-branch-and-pull-request/).
2. Create your feature branch. (`git checkout -b my-new-feature`)
3. Commit your changes. (`git commit -am 'new feature'`)
4. Push the branch. (`git push origin my-new-feature`)
5. Create a new [pull request](https://help.github.com/articles/using-pull-requests).

## Author

* [Jeff Nyman](http://testerstories.com)

## Credits

This code is based upon the [YmlReader](https://github.com/cheezy/yml_reader) gem. I wanted to give myself room to make a more generic version that may not be focused only on YAML files. More importantly, I wanted to clean up the implementation and documentation a bit.

## License

DataReader is distributed under the [MIT](http://www.opensource.org/licenses/MIT) license.
See the [LICENSE](https://github.com/jnyman/data_reader/blob/master/LICENSE.txt) file for details.
