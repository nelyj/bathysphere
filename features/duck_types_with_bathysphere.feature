Feature: Easy duck typing
  As a developer who manages products with different kinds of options
  In order to ensure they all behave the same
  I want to implement configuration-driven duck types

  Scenario:
    Given a file named "config/products/fruit.yml" with:
      """
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
      """
    And a file named "config/products/vehicle.yml" with:
      """
      ---
      display_name:
        key: 'size'
        values:
          large: 'Train'
          medium: 'Bus'
          small: 'Bike'
      """
    And a file named "example_duck_types_with_bathysphere.rb" with:
      """
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

      class Fruit < Product

        def initialize(size, color)
          @size = size
          @color = color
        end

        def display_name
          configuration.fetch(:display_name, @size, @color)
        end
      end

      class Vehicle < Product

        def initialize(size)
          @size = size
        end

        def display_name
          configuration.fetch(:display_name, @size)
        end
      end

      products = [
        Fruit.new(:large, :purple),
        Vehicle.new(:small),
        Fruit.new(:small, :green),
        Fruit.new(:small, :orange),
        Vehicle.new(:large),
      ]

      puts "All products have a display name."
      puts products.map(&:display_name).inspect

      """
      When I run `ruby example_duck_types_with_bathysphere.rb`
      Then the output should contain:
      """
      All products have a display name.
      ["Eggplant", "Bike", "Grape", "Kumquat", "Train"]
      """

