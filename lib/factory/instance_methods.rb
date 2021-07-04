# frozen_string_literal: true

class Factory
  module InstanceMethods
    extend Forwardable
    include Comparable

    def_delegators :context, :to_h
    def_delegators :to_h, :dig, :each_pair
    def_delegators :members, :length, :size
    def_delegators :to_a, :each, :select, :values_at

    def members
      self.class.members
    end

    def initialize(*args)
      if args.count != members.count
        raise ArgumentError, "wrong number of arguments (given #{args.count}, expected #{members.count})"
      end

      members.each_with_index { |property, index| instance_variable_set("@#{property}", args[index]) }
    end

    def context
      members.map { |member| [member, instance_variable_get("@#{member}")] }
    end

    def <=>(other)
      context <=> other.context
    end

    def [](property)
      instance_variable_get(property.is_a?(Integer) ? instance_variables[property] : "@#{property}")
    rescue TypeError
      nil
    end

    def []=(property, value)
      instance_variable_set(property.is_a?(Integer) ? instance_variables[property] : "@#{property}", value)
    rescue TypeError
      nil
    end

    def to_a
      context.map(&:last)
    end
  end
end
