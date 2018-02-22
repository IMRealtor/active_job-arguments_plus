require 'logger'

begin
  require 'ph_model'
rescue LoadError
  # ignore
end

require 'active_job/arguments'
require 'globalid'
require_relative 'arguments_plus/version'

ActiveJob::Arguments # pre-load so we extend the module

module ActiveJob
  module ArgumentsPlus
    def self.type_keys
      @type_keys ||= begin
        add_if_defined = lambda { |tk, klass_name|
          tk[klass_name.constantize] = "_aj_#{klass_name.underscore}" if const_defined?(klass_name)
        }
        tk = {}
        add_if_defined.call(tk, 'Module')
        add_if_defined.call(tk, 'Logger')
        add_if_defined.call(tk, 'PhModel')
        add_if_defined.call(tk, 'Time')
        tk
      end
    end

    def serialize_argument(argument)
      arg_klass, _ = type_keys.find { |klass, _| klass === argument }
      arg_klass ? serialize_local_argument(arg_klass, argument) : super
    end

    def deserialize_argument(argument)
      if argument.is_a?(Hash) && argument.size == 1
        arg_klass, _ = type_keys.find { |_, key| argument.key?(key) }
        arg_klass ? deserialize_local_argument(arg_klass, argument) : super
      else
        super
      end
    end

    private

    def serialize_local_argument(arg_klass, argument)
      value = send("serialize_#{class_to_method(arg_klass.name)}", argument)
      serialize_generic(arg_klass, value)
    end

    def deserialize_local_argument(arg_klass, argument)
      value = deserialize_generic(arg_klass, argument)
      send("deserialize_#{class_to_method(arg_klass.name)}", value)
    end

    delegate :type_keys, to: 'ActiveJob::ArgumentsPlus'

    def class_to_method(klass_name)
      klass_name.underscore
    end

    def key_for(klass)
      case type_keys[klass]
      when Hash
        type_keys[klass][:key]
      else
        type_keys[klass]
      end
    end

    def serialize_generic(klass, value)
      {key_for(klass) => value}
    end

    def deserialize_generic(klass, argument)
      argument[key_for(klass)]
    end

    def serialize_logger(_)
      true
    end

    def deserialize_logger(_)
      # Yes this is kinda lame, but loggers can't really be serialized ...
      Logger.new(STDOUT)
    end

    def serialize_module(klass)
      klass.name
    end

    def deserialize_module(klass_name)
      klass_name.constantize
    end

    def serialize_ph_model(model)
      {
        'type' => model.class.name,
        'data' => model.as_json,
      }
    end

    def deserialize_ph_model(info)
      info['type'].constantize.send(:build, info['data'])
    end

    def serialize_time(time)
      time.to_f
    end

    def deserialize_time(unixtime)
      Time.at(unixtime)
    end
  end

  module Arguments
    extend ArgumentsPlus
  end
end
