# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

require 'forwardable'
require_relative 'factory/instance_methods'

class Factory
  class << self
    def new(*args, &extra_behavior)
      creatable = creatable(args)
      class_args = args.map(&:to_sym)
      creatable.instance_variable_set(:@members, class_args)
      class_args.each { |arg| creatable.send(:attr_accessor, arg) }
      creatable.class_eval(&extra_behavior) if extra_behavior
      creatable
    end

    private

    def creatable(args)
      creatable = Class.new do
        class << self
          attr_reader :members
        end
        include InstanceMethods
      end
      args.first.is_a?(String) ? Factory.const_set(args.shift.to_s.capitalize, creatable) : creatable
    end
  end
end
