Intended API
============

This document is intended to allow discussing the Bathysphere API before it is implemented.

Its contents will be moved to the gem [`README`][readme] when the corresponding features are implemented.

  [readme]: ../README.md

Usage
-----

### Basics

_Here go all the current usage instractions._

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

Installation
------------

Add the gem to your `Gemfile`:

```ruby
# Gemfile

gem 'bathysphere', '~> 1,0' # see semver.org
```

