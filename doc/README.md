Intended API
============

This document is intended to allow discussing the Bathysphere API before it is implemented.

Its contents will be moved to the gem [`README`][readme] when the corresponding features are implemented.

  [readme]: ../README.md

Installation
------------

Add the gem to your `Gemfile`:

```ruby
# Gemfile

gem 'bathysphere', '~> 1,0' # see semver.org
```

Usage
-----

Define your configuration files. The `key` is the self-documenting part of the configuration file, and it defines how deep the `values` must be fetched:


```yaml
# config/products/fruits.yml

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
# config/product/vehicles.yml

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
    super
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
    super
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
  Fruit.new(:small, :red),
  Fruit.new(:small, :yellow),
  Vehicle.new(:large),
]

products.map(&display_name)
# => ["Eggplant", "Bike", "Strawberry", "Kumquat", "Train"]
```

