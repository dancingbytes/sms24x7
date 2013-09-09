# encoding: utf-8
module Sms24x7

  class Error < ::StandardError; end

  class ConnectionError < ::Sms24x7::Error; end

  class AuthError < ::Sms24x7::Error; end

  class SessionExpiredError < ::Sms24x7::Error; end

  class TimeoutError < ::Sms24x7::Error; end

  class RespondError < ::Sms24x7::Error; end

  class ArgumentError < ::Sms24x7::Error; end

  class InactiveError < ::Sms24x7::Error; end

  class UnknownError < ::Sms24x7::Error; end

end # Sms24x7
