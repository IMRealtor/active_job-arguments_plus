require 'logger'

begin
  require 'ph_model'
rescue LoadError
  # ignore
end

require 'active_job/arguments'
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
        tk
      end
    end

    def serialize_argument(argument)
      arg_klass, info = type_keys.find { |klass, _| klass === argument }
      arg_klass ? send("serialize_#{class_to_method(arg_klass.name)}", argument) : super
    end

    def deserialize_argument(argument)
      if argument.is_a?(Hash) && argument.size == 1
        arg_klass, _ = type_keys.find { |_, key| argument.key?(key) }
        arg_klass ? send("deserialize_#{class_to_method(arg_klass.name)}") : super
      else
        super
      end
    end

    private

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

    def serialize_logger(_)
      { key_for(Logger) => true }
    end

    def deserialize_logger(_)
      # Yes this is kinda lame, but loggers can't really be serialized ...
      Logger.new(STDOUT)
    end

    def serialize_module(argument)
      { key_for(Logger) => argument.name }
    end

    def deserialize_module(argument)
      argument[key_for(Logger)].constantize
    end

    def serialize_ph_model(argument)
      {
        key_for(PhModel) => {
          'type' => argument.class.name,
          'data' => argument.as_json,
        }
      }
    end

    def deserialize_ph_model(argument)
      info = argument[key_for(PhModel)]
      info['type'].constantize.send(:build, info['data'])
    end
  end

  module Arguments
    extend ArgumentsPlus
  end
end
