Bathysphere
===========

[![Gem Version](https://badge.fury.io/rb/bathysphere.svg)](http://badge.fury.io/rb/bathysphere)
[![Build Status](https://travis-ci.org/redbubble/bathysphere.svg?branch=master)](https://travis-ci.org/redbubble/bathysphere)
[![Code Climate](https://codeclimate.com/github/redbubble/bathysphere.svg)](https://codeclimate.com/github/redbubble/bathysphere)
[![Dependency Status](https://gemnasium.com/redbubble/bathysphere.svg)](https://gemnasium.com/redbubble/bathysphere)
[![Inline docs](http://inch-ci.org/github/redbubble/bathysphere.svg?branch=master)](http://inch-ci.org/github/redbubble/bathysphere)

Fetch arbitrarily deep properties from YAML files without loosing your breath.

Bathysphere takes benefit of a self-describing YAML-based data format to
normalize options fetching, so the same option can be stored at different
depths in distinct configuration files.

> **DISCLAIMER**: This is an early version of Bathysphere, please be aware that it will not be stable until `v1.0.0`. Until then you can consult the [intended API][intent] and, at any moment, [feedback][issues] is welcome! : ) -- [GB][gonzalo-bulnes]

  [intent]: doc/README.md
  [gonzalo-bulnes]: https://github.com/gonzalo-bulnes
  [issues]: https://github.com/redbubble/bathysphere/issues

Installation
------------

Add the gem to your `Gemfile`:

```ruby
# Gemfile

gem 'bathysphere', '0.2.0' # see semver.org
```

  [gemfury]: https://gemfury.com

Usage
-----

### Basics

Define your configuration files. The `key` is the self-documenting part of the configuration file, and it defines how deep the `values` must be fetched:


```yaml
# config/products/fruit.yml

---
display_name:
  key: 'size,color'
  values:
    small:
      green: 'Grape'
      orange: 'Kumquat'
      purple: 'Blueberry'
    medium:
      green: 'Pear'
      orange: 'Orange'
      purple: 'Plum'
    large:
      green: 'Watermelon'
      orange: 'Melon'
      purple: 'Eggplant'
```

```yaml
# config/product/vehicle.yml

---
display_name:
  key: 'size'
  values:
    large: 'Train'
    medium: 'Bus'
    small: 'Bike'
```

Create a `Bathysphere::Parser` for each configuration file (note that you don't need to know how deep the values are defined):


```ruby
# app/models/product.rb

require 'bathysphere'

class Product

  def self.configuration
    @configuration ||= Bathysphere::Parser.new("config/products/#{name}.yml")
  end

  def configuration
    self.class.configuration
  end

  def display_name
    raise NotImplementedError
  end
end
```

The same `Bathysphere::Parser#fetch` method can be used to fetch all the `display_name` values, using exactly the required arguments:

```ruby
# app/models/fruit.rb

class Fruit < Product

  def initialize(size, color)
    @size = size
    @color = color
  end

  def display_name
    configuration.fetch(:display_name, @size, @color)
  end
end
```

```ruby
# app/models/vehicle.rb

class Vehicle < Product

  def initialize(size)
    @size = size
  end

  def display_name
    configuration.fetch(:display_name, @size)
  end
end
```

A nice and easy way to implement duck types for different kinds of products!


```ruby
# anywhere

products = [
  Fruit.new(:large, :purple),
  Vehicle.new(:small),
  Fruit.new(:small, :green),
  Fruit.new(:small, :orange),
  Vehicle.new(:large),
]

products.map(&display_name)
# => ["Eggplant", "Bike", "Grape", "Kumquat", "Train"]
```

### Further automation

Sometimes, defining the reader methods for the configurable properites is not practical. (Maybe your products are generated dynamically, or you want to keep the duck type obvious by keeping these readers in the `Product` class.)

Optionally, the additional arguments to the `Parser#fetch` method can be retrieved automatically from any object provided to the `Parser#using` method:

```ruby
# app/models/product.rb

require 'bathysphere'

class Product

  def self.configuration
    @configuration ||= Bathysphere::Parser.new("config/products/#{name}.yml")
  end

  def configuration
    self.class.configuration
  end

  def display_name
    # Note that only :display_name was provided as an argument to Parser#fetch,
    # the additional arguments will be retrieved by calling the corresponding
    # reader methods on whatever object is provided to Parser#using, which in
    # this case is the product instance.
    configuration.using(self).fetch(:display_name)
  end
end
```

```ruby
# app/models/fruit.rb

class Fruit < Product

  # These readers will be automatically called by Bathysphere::Parser#fetch
  # to retrieve the Fruit#display_name - note that the parser is using(self)
  attr_reader :color, :size

  def initialize(size, color)
    @size = size
    @color = color
  end
end
```

```ruby
# app/models/vehicle.rb

class Vehicle < Product

  # This reader will be automatically called by Bathysphere::Parser#fetch
  # to retrieve the Vehicle#display_name - note that the parser is using(self)
  attr_reader :size

  def initialize(size)
    @size = size
  end
end
```

Contributions
-------------

Contributions are welcome! Please feel free to open issues or pull requests to get help or discuss ideas or implementations. Note that opening pull requests with work in progress is not only welcome, but encouraged! Talk early, talk often, and we will all learn in the way :)

Finally, please note that this project is released with a [Contributor Code of Conduct][coc]. By participating in this project you agree to abide by its terms.

  [coc]: ./CODE_OF_CONDUCT.md

Credits
-------

[![](doc/redbubble.png)][redbubble]

Bathysphere is maintained and funded by [Redbubble][redbubble].

  [redbubble]: https://www.redbubble.com

License
-------

		Bathysphere
		Copyright (C) 2016, 2017 Redbubble

		Permission is hereby granted, free of charge, to any person obtaining
		a copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:

		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

