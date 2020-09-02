# Copyright (c) 2020 Bryan Frimin <bryan@frimin.fr>.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

require("time")
require("json")
require_relative("rb-logger/standard_logger")

module RbLogger
  class Error < StandardError; end
  class Message < Struct.new(:time, :level, :domain, :text, :data, keyword_init: true); end

  module Formatter
    def self.json
      lambda do |message|
        message.data.merge({ts: message.time, domain: message.domain,
                            message: message.text, level: message.level}).to_json + "\n"
      end
    end
  end

  def new_logger(domain, formatter: Formatter.json, data: {}, device: $stderr)
    Logger.new(domain, formatter: formatter, data: data, device: device)
  end
  module_function :new_logger

  class Logger
    # Returns a new instance of Logger.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param [String, Symbol] domain the name of the logger
    # @param formatter [#call]
    # @param data [Hash<String, Object>, Hash<Symbol, Object>] data a set of default data
    # @param device [#puts]
    #
    # @return [Logger]
    def initialize(domain, formatter:, data:, device:)
      @domain = domain.to_s
      @formatter = formatter
      @data = data
      @device = device
    end

    # Create a new logger instance from the current one.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param [String, Symbol] domain the name of the logger
    # @param [Hash<String, Object>, Hash<Symbol, Object>] data a set of default data
    #
    # @return [Logger]
    #
    # @example
    #   logger.new_child("sidekiq", {hostname: ENV["HOST"]}) #=> Logger
    def new_child(domain, data = {})
      domain = "#{@domain}.#{domain}"
      data = @data.merge(data)
      self.class.new(domain, formatter: @formatter,
                     data: data, device: @device)
    end

    # Transform RbLogger::Logger into the standard Ruby logger.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @return [StandardLogger]
    #
    # @example use rb-logger with an external library or framework
    #   Rails.logger = logger.to_std()
    def to_std
      StandardLogger.new(self)
    end

    # Log a message.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param [String, Symbol] level the level of the log message (e.g. info, error)
    # @param [String] text the log message
    # @param [Hash<String, Object>, Hash<Symbol, Object>] data
    #
    # @return [nil]
    #
    # @example
    #   logger.log(:info, "hello world", {response_code: 42}) #=> nil
    def log(level, text, data)
      # https://bugs.ruby-lang.org/issues/13231
      time = Time.now.utc.to_datetime.strftime("%FT%T")+"Z"
      message = Message.new(level: level, text: text, domain: @domain,
                            data: @data.merge(data), time: time)
      log = @formatter.call(message)
      @device.puts(log)
      nil
    end

    # Log an info message.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param (see Kernel#sprintf)
    #
    # @return [nil]
    #
    # @example log info message without formatting argument
    #   logger.info("hello world") #=> nil
    #
    # @example log info message with format arguments
    #   logger.info("%s => %p", "hello", Object.new) #=> nil
    def info(format, *args)
      log(:info, sprintf(format, *args), {})
    end

    # Log an info message with data.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param [Hash<String, Object>, Hash<Symbol, Object>] data
    # @param (see Kernel#sprintf)
    #
    # @return [nil]
    #
    # @example log info message with data without formatting argument
    #   logger.info({foo: "bar", baz: Object.new}, "hello world") #=> nil
    #
    # @example log info message with data and formatting arguments
    #   logger.info({foo: "bar"}, "hello %s", "world") #=> nil
    def info_data(data, format, *args)
      log(:info, sprintf(format, *args), data)
    end

    # Log an error message.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param (see Kernel#sprintf)
    #
    # @return [nil]
    #
    # @example log error message without formatting argument
    #   logger.error("internal error") #=> nil
    #
    # @example log error message with formatting arguments
    #   logger.error("response with %d http code", 500)
    def error(format, *args)
      log(:error, sprintf(format, *args), {})
    end

    # Log an error message with data.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param [Hash<String, Object>, Hash<Symbol, Object>] data
    # @param (see Kernel#sprintf)
    #
    # @return [nil]
    #
    # @example log error message with data without formatting argument
    #   logger.error({http_code: 500, http_verb: "POST"}, "response with 5xx http code") #=> nil
    #
    # @example log error message with data and formatting arguments
    #   logger.error({http_code: 500, http_verb: "POST"}, "response with %d http code", 500) #=> nil
    def error_data(data, format, *args)
      log(:error, sprintf(format, *args), data)
    end

    # Log an error message and exit with error.
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param (see Kernel#sprintf)
    #
    # @return [nil]
    #
    # @example log error message without formatting argument and exit
    #   logger.fatal("cannot read the configuration file")
    #
    # @example log error message with formatting arguments and exit
    #   logger.fatal("cannot read the configuration file: %p", StandardError.new("foo"))
    def fatal(format, *args)
      log(:error, sprintf(format, *args), {})
    ensure
      exit(1)
    end

    # Log an error message with data and exit with error.
    #
    # @author Gearnode <bryan@frimin.fr>
    # @since 1.0.0
    #
    # @param [Hash<String, Object>, Hash<Symbol, Object>] data
    # @param (see Kernel#sprintf)
    #
    # @return [nil]
    #
    # @example log error message with data, without formatting argument and exit
    #   logger.fatal({pg_conn_pid: 30}, "detected connection leak ouside the connection pool")
    #
    # @example log error message with data with formatting arguments and exit
    #   logger.fatal({boot_phase: 2}, "invalid configuration key %p for pg component", "dummy")
    def fatal_data(data, format, *args)
      log(:error, sprintf(format, *args), data)
    ensure
      exit(1)
    end
  end
end
