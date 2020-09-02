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

require("logger")

module RbLogger
  class StandardLogger < ::Logger
    def initialize(logger)
      @logger = logger
    end

    def <<(message)
      add(::Logger::INFO, message, nil)
    end

    def add(severity, message = nil, progname = nil)
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end

      case severity
      when ::Logger::ERROR
        @logger.error(message)
      when ::Logger::FATAL
        @logger.fatal(message)
      when ::Logger::INFO
        @logger.info(message)
      when ::Logger::UNKNOWN
        @logger.error(message)
      when ::Logger::WARN
        @logger.error(message)
      else
        nil
      end
    end

    def close(_severity, _message = nil, _progname = nil); end

    def datetime_format; end

    def datetime_format=(_datetime_format); end

    def debug(_progname = nil, &block); end

    def debug?; false; end

    def error(progname = nil, &block)
      add(::Logger::DEBUG, nil, progname, &block)
    end

    def error?; true; end

    def fatal(progname = nil, &block)
      add(::Logger::FATAL, nil, progname, &block)
    end

    def fatal?; true; end

    def info(progname = nil, &block)
      add(::Logger::INFO, nil, progname, &block)
    end

    def info?; true; end

    def level=(_severity); end

    def log(severity, message = nil, progname = nil)
      add(severity, message, progname)
    end

    def reopen; self; end

    def sev_threshold=(_severity); end

    def unknown(progname = nil, &block)
      add(::Logger::UNKNOWN, nil, progname, &block)
    end

    def warn(progname = nil, &block)
      add(::Logger::WARN, nil, progname, &block)
    end

    def warn?; true; end
  end
end
