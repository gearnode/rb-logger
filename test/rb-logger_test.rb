require("test_helper")
require("stringio")

class RbLoggerTest < Minitest::Test

  def before_setup
    @dev = StringIO.new
    @logger = RbLogger.new_logger("mytestapp", device: @dev)
  end

  def test_info
    @logger.info("message without formatting argument")
    @logger.info("message with formatting %s", "argument")

    @dev.rewind

    log = JSON.parse(@dev.gets)
    assert_log_message("message without formatting argument", log)
    assert_log_level("info", log)
    assert_log_domain("mytestapp", log)


    log = JSON.parse(@dev.gets)
    assert_log_message("message with formatting argument", log)
    assert_log_level("info", log)
    assert_log_domain("mytestapp", log)
  end

  def test_info_data
    @logger.info_data({k: :v}, "hello message")
    @logger.info_data({v: :k}, "hello message %d", 42)

    @dev.rewind

    log = JSON.parse(@dev.gets)
    assert_log_level("info", log)
    assert_log_domain("mytestapp", log)
    assert_log_message("hello message", log)
    assert_equal("v", log["k"])

    log = JSON.parse(@dev.gets)
    assert_log_level("info", log)
    assert_log_domain("mytestapp", log)
    assert_log_message("hello message 42", log)
    assert_equal("k", log["v"])
  end

  def test_error
    @logger.error("error message")
    @logger.error("error message %p", "foo")

    @dev.rewind

    log = JSON.parse(@dev.gets)
    assert_log_message("error message", log)
    assert_log_level("error", log)
    assert_log_domain("mytestapp", log)

    log = JSON.parse(@dev.gets)
    assert_log_message("error message \"foo\"", log)
    assert_log_level("error", log)
    assert_log_domain("mytestapp", log)
  end

  def test_error_data
    @logger.error_data({k: :v}, "error message data")
    @logger.error_data({v: :k}, "hello message %s", "data")

    @dev.rewind

    log = JSON.parse(@dev.gets)
    assert_log_level("error", log)
    assert_log_domain("mytestapp", log)
    assert_log_message("error message data", log)
    assert_equal("v", log["k"])

    log = JSON.parse(@dev.gets)
    assert_log_level("error", log)
    assert_log_domain("mytestapp", log)
    assert_log_message("hello message data", log)
    assert_equal("k", log["v"])
  end

  def test_fatal
    prgm = fork do
      @logger.fatal("fatal error !!!")
    end

    _, status = Process.waitpid2(prgm)

    refute status.success?
  end

  def assert_log_level(exp, log, msg = "")
    msg = message(msg, "") { diff(exp, log["level"]) }
    assert(exp == log["level"], msg)
  end

  def assert_log_domain(exp, log, msg = "")
    msg = message(msg, "") { diff(exp, log["domain"]) }
    assert(exp == log["domain"], msg)
  end

  def assert_log_message(exp, log, msg = "")
    msg = message(msg, "") { diff(exp, log["message"]) }
    assert(exp == log["message"], msg)
  end
end
