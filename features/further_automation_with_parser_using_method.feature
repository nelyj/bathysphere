Feature: Further automation with Parser#using
  As a developer
  In order to be able to use Bathysphere with dynamically generated classes
  I want all the arbirarily-deep properties readers to be similar
  And I don't want them to require specific arguments to be used in Parser#fetch
  But I'm fine with defining an object to take place of these specific arguments

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
    And a file named "further_automation_with_bathysphere_parser_using_method.rb" with:
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
          configuration.using(self).fetch(:display_name)
        end
      end

      class Fruit < Product

        attr_reader :color, :size

        def initialize(size, color)
          @size = size
          @color = color
        end
      end

      class Vehicle < Product

        attr_reader :size

        def initialize(size)
          @size = size
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
      When I run `ruby further_automation_with_bathysphere_parser_using_method.rb`
      Then the output should contain:
      """
      All products have a display name.
      ["Eggplant", "Bike", "Grape", "Kumquat", "Train"]
      """

