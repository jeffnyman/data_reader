# DataReader

[![Gem Version](https://badge.fury.io/rb/data_reader.svg)](http://badge.fury.io/rb/data_reader)
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jeffnyman/data_reader/blob/master/LICENSE.md)

The DataReader gem is used to provide a standard mechanism for providing a YAML data path and loading data from it. DataReader is mainly used as a support gem that can be included by other libraries that need this functionality.

## Installation

To get the latest stable release, add this line to your application's Gemfile:

```ruby
gem 'data_reader'
```

To get the latest code:

```ruby
gem 'data_reader', git: 'https://github.com/jeffnyman/data_reader'
```

After doing one of the above, execute the following command:

```
$ bundle
```

You can also install DataReader just as you would any other gem:

```
$ gem install data_reader
```

## Usage

The basic idea of DataReader is simple: you set a data path and DataReader will load data files from that path. But there are some nuances that it's worth discussing in this documentation.

### Including DataReader

You can include the DataReader in a class or module.

```ruby
require "data_reader"

class Testing
  include DataReader
end
```

This will provide DataReader functionality on any instance of the class where DataReader is mixed in.

DataReader does not set defaults for anything. It provides a `data_path` variable that you can set. It also provides a `data_contents` variable that will be populated with the result of a data file that gets loaded from any specified data path.

### Data Paths

Consider the following file and directory setup:

```
project_dir\
  combined\
    invalid.yml
    conditions.yml
    stars.yml

  provision\
    invalid.yml

  stardates\
    conditions.yml

  warp\
    stars.yml
```

This is in fact the structure that is provided as part of the `examples` directory with this repository.

Within the `project_dir` you could create a file called `script.rb` to see how DataReader works. Put the above class in place in that file and then add this:

```ruby
test = Testing.new

puts test.data_path
puts test.data_contents
```

This would print nothing for either of those values, showing that they have no default values. You could now do this:

```ruby
test.data_path = 'warp'

puts test.data_path
```

Here you are setting the `data_path` to a directory called `warp`. The `puts` statement after that simply confirms that this was set. This has now set the data path for DataReader. Here the "data path" indicates where DataReader will look for data files. Thus you could load any file that is in that directory:

```ruby
test.load 'stars.yml'
```

Loading causes the data from the file to be put into a `data_contents` attribute.


```ruby
puts test.data_contents
```

The `puts` call for the `data_contents` will show you the contents of the `stars.yml` file.

You could set the data contents on the class instance if you wanted to:

```ruby
class Testing
  include DataReader

  def data
    @data_contents
  end
end
```

Now you can access the data via:

```ruby
puts test.data
```

The reason this might be useful is because the data contents may change, such as if you read different files at different times, but this way you refer to the relevant contents via one variable.

Note that you can change the data path on the fly if you need to. For example:

```ruby
test.data_path = 'stardates'

test.load 'conditions.yml'
```

This would set the data path to the `stardates` directory and then the load file would grab the contents of the `conditions.yml` file.

### Data Path on Class

You could have specified the `data_path` as a method on the class instead, like this:

```ruby
class Testing
  include DataReader

  def data_path
    'provision'
  end
end
```

Then you don't have to set the path specifically as we've been doing.

Note that if you are setting the `data_path` on the class, the idea is that you want this to be the data path. So it can't be reassigned. To see that, try the above and the have the script logic as such:

```ruby
test.data_path = 'provision'
test.load 'invalid.yml'
```

This would lead to an error because while you have set the `data_path`, that will not override what has been set on the class. So the upshot is that if you define a `data_path` as a method on the class, that's what will be used even if you re-define the `data_path` on a specific instance of that class.

### Default Data Path

You may want to make sure that a default data path is always available should a data path not have been specifically set. You can do that as follows:

```ruby
class Testing
  include DataReader

  def default_data_path
    'provision'
  end
end
```

Keep in mind that DataReader will always favor whatever it has stored in `data_path`. The `default_data_path` can be used for a fallback. So, with the default data path specifed as above, consider this:

```ruby
test = Testing.new

test.load 'invalid.yml'
puts test.data_contents
```

This owuld work just fine. But if you were to set the data path, that overrides the default:

```ruby
test.data_path = 'warp'
test.load 'invalid.yml'
```

Here I've set the `data_path` but I'm still trying to load `invalid.yml` (which is in the `provision` directory). But the `data_path`, since it's set, overrides that. The upshot is that a specific data path overrides the default.

If you want to be able to revert to the default, you need to set the `data_path` to nil.

### Note that named sections will currently cause a failure. So for example:

```yaml
users: &users
  admin:
  - username: admin
  	password: admin
```

This would fail to load based on the `&users` part.

### Multiple Data Files

You can load multiple YAML files. The `load` method takes a list of comma separated names of files that are in that same directory. So if you were to place all the above example YAML files in one directory, such as the `combined` directory shown above, you could do this:

```ruby
test.data_path = 'combined'

test.load 'stars.yml, conditions.yml, invalid.yml'
```

When loading in multiple files, the `data_contents` will hold the contents of all the files in the list.

### Multiple Data Sources

You don't have to use the `data_context` value. For example, you could do this:

```ruby
stars = test.load 'stars.yml'
invalid = test.load 'invalid.yml'
```

In this case, the appropriate data would be stored in each variable. Do note that `data_context` will always contain the last data read by the `load` method. So in the above case, `data_context` would contain the contents of `invalid.yml` even if you never intended to use that variable.

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
test.load 'config.yml'
puts test.data_contents
```

Assuming the BROWSER environment variable was set, the `data_contents` variable would look as follows:

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

The support for ERB allows for custom method calls. One that is included with DataReader is `include_data`. First consider the directory structure:

```
included\
  included_nested.yml
  included.yml
  with_includes.yml
  with_nested_includes.yml
```

In the `with_includes.yml` file, there is a line like this:

```yaml
<%= include_data("included.yml") %>
```

Now you can do this:

```ruby
test.data_path = 'included'

test.load 'with_includes.yml'
```

This will load up `with_includes.yml` and, because of the `include_data` call would attempt to load the file `included.yml`.

In this case, the value of `data_contents` would contain both data sets, first the data from `with_includes.yml` and then the data from `included.yml`.

Note, however, that DataReader will attempt to load this from the same location as `with_includes.yml`. You can absolute or relative paths as part of the call, as such:

```yaml
<%= include_data("../warp/stars.yml") %>
````

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec:all` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

The default `rake` command will run all tests as well as a RuboCop analysis.

To install this gem onto your local machine, run `bundle exec rake install`.

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
See the [LICENSE](https://github.com/jeffnyman/data_reader/blob/master/LICENSE.md) file for details.
