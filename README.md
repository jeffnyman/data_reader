# DataReader

[![Gem Version](https://badge.fury.io/rb/data_reader.svg)](http://badge.fury.io/rb/data_reader)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jeffnyman/data_reader/blob/master/LICENSE.txt)

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

This will provide DataReader functionality on any instance of the class where DataReader is mixed in.

DataReader does not set defaults for anything. It provides a `data_path` variable that you can set. It also provides a `data_source` variable that will be populated with the result of a file that gets loaded from any specified data path.

### Data Paths

Consider the following file and directory setup:

```
project_dir\
  config\
    config.yml

  data\
    stars.yml

  env\
    environments.yml
	
  example-data-reader.rb
```

All the code shown below would go in the `example-data-reader` file.

With the above class in place and the above directory structure, you could do this:

```ruby
test = Testing.new

test.data_path = 'data'

puts test.data_path

test.load 'stars.yml'

puts test.data_source
```

Here you are setting the `data_path` to a directory called `data`. The `puts` statement after that simply confirms that this was set. You then call the `load` method for a YAML file that is in that directory. The `puts` call for the `data_source` will show you the contents of the YAML.

### Data Path on Class

You could have specified the `data_path` as a method of the class instead, like this:

```ruby
class Testing
  include DataReader

  def data_path
    'data'
  end
end
```

Then you don't have to set the path specifically on the instance.

### Multiple Data Files

You can load multiple YAML files. The `load` method takes a list of comma separated names of files that are in that same directory. So if you were to place all the above example YAML files in one directory, you could do this:

```ruby
load 'config.yml, environments.yml, stars.yml'
```

When loading in multiple files, the `data_source` will hold the contents of all the files in the list.

### Multiple Data Sources

You don't have to use the `data_source` value. For example, you could do this:

```ruby
configs = app.load 'config.yml'
envs = app.load 'environments.yml'
```

In this case, the appropriate data would be stored in each variable. Do note that `data_source` will always contain the last data read by the `load` method. So in the above case, `data_source` would contain the contents of `environments.yml` even if you never intended to use that variable.

### Setting a Data Pata

You can, at any time, set a data path. When you do, any calls to `load` will use that data path. Consider this example:

```ruby
app.data_path = 'config'
configs = app.load 'config.yml'

app.data_path = 'env'
envs = app.load 'environments.yml'
```

Do note that if you had defined a `data_path` method in your class, as shown above, that will always overridde a local instance setting as shown in the preceding code.

### Default Data Path

You may want to make sure that a default data path is always available should a data path not have been specifically set. You can do that as follows:

```ruby
class Testing
  include DataReader

  def default_data_path
    'data'
  end
end
```

Keep in mind that DataReader will always favor whatever it has stored in `data_path`. The `default_data_path` can be used for a fallback. So, with the default data path specifed as above, consider this:

```ruby
test = Testing.new

test.load 'stars.yml'
puts test.data_source

test.data_path = 'config'
configs = test.load 'config.yml'
puts test.data_source
```

Here the first `load` call works by using the default path. Then a data path is set and a file loaded from that path. Once that data path has been set, the default data path is no longer going to be used. If you want to be able to revert to the default, you need to set the `data_path` to nil. For example, here's the same code as the preceding with a few additions at the end:

```ruby
test = Testing.new

test.load 'stars.yml'
puts test.data_source

test.data_path = 'config'
configs = test.load 'config.yml'
puts test.data_source

app.data_path = nil

app.load 'stars.yml'
puts app.data_source
```

The second call to load the `stars.yml` file reverts to using the default data path.

### Parameterizing Data

You can set environment variables in YAML files. To do this you have to use ERB, like this:

```yaml
<%= ENV['XYZZY'] %>
```

To handle this, DataReader parses any values with ERB before it parses the YAML itself. Here's an example YAML file:

```yaml
config:
  current:
    server: test
    user: jeff_nyman
    browser: <%= ENV['BROWSER'] %>
```

Now let's say I loaded up this file and looked at the data source:

```ruby
app.load 'config.yml'
puts app.data_source
```

Assuming the BROWSER environment variable was set, the `data_source` variable would look as follows:

```
{
    "config" => {
        "current" => {
             "server" => "test",
               "user" => "jeff_nyman",
            "browser" => "chrome"
        }
    }
}
```

### Method Calls on Data

The support for ERB allows for custom method calls. One that is included with DataReader is `include_data`, which can be used like this:

```yaml
<%= include_data("config.yml") %>
```

Say that this line was included in line was in the YAML `environment.yml` from the above structure and you did this:

```ruby
app.data_path = 'env'
app.load 'environments.yml'
```

This will load up `environments.yml` and, because of the `include_data` call would attempt to load the file `config.yml`. Note, however, that DataReader will attempt to load this from the same location as `environments.yml`. You can absolute or relative paths as part of the call, as such:

```yaml
<%= include_data("../config/config.yml") %>
````

In this case, the value of `data_source` would contain both data sets, first the data from `config.yml` and then the data from `environments.yml`.

### Extending DataReader

You can also extend, rather than include, DataReader. This means you deal with the class rather than an instance of it. For example:

```ruby
require "data_reader"

class Testing
  extend DataReader
end

Testing.data_path = 'config'

puts Testing.data_path

Testing.load 'config.yml'

puts Testing.data_source
```

Note that you can provide methods as you did in the include case, but make sure they are defined on `self`. For example:

```ruby
class Testing
  extend DataReader

  def self.data_path
    'config'
  end
end
```

If you were using `default_data_path`, likewise just make sure you prepend `self` to it.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec:all` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/jeffnyman/data_reader](https://github.com/jeffnyman/data_reader). The testing ecosystem of Ruby is very large and this project is intended to be a welcoming arena for collaboration on yet another testing tool. As such, contributors are very much welcome but are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

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
See the [LICENSE](https://github.com/jeffnyman/data_reader/blob/master/LICENSE.txt) file for details.
