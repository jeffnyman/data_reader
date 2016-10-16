# DataReader

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

You can extend the DataReader to use it in another class or module.

```ruby
class DataBuilder
  extend DataReader
end
```

By extending the DataReader module you have three methods and two instance variables available to you. The three methods:

* `data_path=`
* `data_path`
* `load`

The instance variables:

* `@data_path`
* `@data_source`

The `@data_path` instance variable will contain a reference to the location where the YAML file (or files) can be found. The `@data_source` instance variable will contain the contents of the YAML file after a call to `load`.

### Multiple Data Files

The `load` method can be used in two ways.

First, it can take the name of a file that is in the directory specified by the `@data_path` instance variable.

```ruby
load 'my_data.yml'
```

Second, it can also take a list of comma separated names of files that are in that same directory.

```ruby
load 'users.yml,accounts.yml,billing.yml'
```

When loading in multiple files, the `@data_source` instance will hold the contents of all the files in the list.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec:all` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/jnyman/data_reader](https://github.com/jnyman/data_reader). The testing ecosystem of Ruby is very large and this project is intended to be a welcoming arena for collaboration on yet another testing tool. As such, contributors are very much welcome but are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

To contribute to Decohere:

1. [Fork the project](http://gun.io/blog/how-to-github-fork-branch-and-pull-request/).
2. Create your feature branch. (`git checkout -b my-new-feature`)
3. Commit your changes. (`git commit -am 'new feature'`)
4. Push the branch. (`git push origin my-new-feature`)
5. Create a new [pull request](https://help.github.com/articles/using-pull-requests).

## Author

* [Jeff Nyman](http://testerstories.com)

## Credits

This code is based upon the [YmlReader](https://github.com/cheezy/yml_reader) gem. I wanted to make a more generic version that may not be focused only on YAML files.

## License

DataReader is distributed under the [MIT](http://www.opensource.org/licenses/MIT) license.
See the [LICENSE](https://github.com/jnyman/data_reader/blob/master/LICENSE.txt) file for details.
