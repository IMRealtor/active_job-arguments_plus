require 'logger'
require 'ph_model'
require 'active_job/arguments'
require_relative 'arguments_plus/version'

ActiveJob::Arguments # pre-load so we extend the module

module ActiveJob
  module ArgumentsPlus
    TYPE_KEYS = {
      Module => '_aj_module',
      Logger => '_aj_logger',
      PhModel => '_aj_ph_model'
    }

    def serialize_argument(argument)
      arg_klass, info = TYPE_KEYS.find { |klass, _| klass === argument }
      arg_klass ? send("serialize_#{class_to_method(arg_klass.name)}", argument) : super
    end

    def deserialize_argument(argument)
      if argument.is_a?(Hash) && argument.size == 1
        arg_klass, _ = TYPE_KEYS.find { |_, key| argument.key?(key) }
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
      case TYPE_KEYS[klass]
      when Hash
        TYPE_KEYS[klass][:key]
      else
        TYPE_KEYS[klass]
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
        key_for(Logger) => {
          'type' => argument.class.name,
          'data' => argument.as_json,
        }
      }
    end

    def deserialize_ph_model(argument)
      info = argument[key_for(Logger)]
      info['type'].constantize.build(info['data'])
    end
  end

  module Arguments
    extend ArgumentsPlus
  end
end
