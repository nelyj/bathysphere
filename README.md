Bathysphere
===========

[![Build Status](https://badge.buildkite.com/48b510c31a0346981a0456d2985675ccd465257cfec6ff9cb4.svg?branch=master)](https://buildkite.com/redbubble/bathysphere)

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

gem 'bathysphere', '0.1.0' # see semver.org
```

Usage
-----

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
display_names:
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

Credits
-------

[![](doc/redbubble.png)][redbubble]

Bathysphere is maintained and funded by [Redbubble][redbubble].

  [redbubble]: https://www.redbubble.com

License
-------

```
Bathysphere
Copyright (C) 2016 Redbubble

All rights reserved.
```

