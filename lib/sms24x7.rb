# encoding: utf-8
require 'uri'
require 'json'
require 'net/http'
require 'timeout'

require 'sms24x7/version'
require 'sms24x7/errors'

module Sms24x7

  extend self

  TIMEOUT   = 30
  HOST      = 'api.sms24x7.ru'
  PORT      = 443
  USE_SSL   = true
  RETRY     = 3
  WAIT_TIME = 5
  PHONE_RE  = /\A(\+7|7|8)(\d{10})\Z/
  TITLE_SMS = "Anlas.ru"

  def login(usr, pass)

    return ::Sms24x7::InactiveError.new("Отправка смс отключена") unless self.active?

    res = ::Sms24x7::Base.sessionid(usr, pass)
    return res if self.error?(res)

    @usr      = usr
    @pass     = pass
    @session  = "sid=#{::CGI::escape(res)}"

    true

  end # login

  def message(phone, msg, opts = {})

    return ::Sms24x7::InactiveError.new("Отправка смс отключена") unless self.active?

    new_phone = ::Sms24x7::convert_phone(phone)

    return ::Sms24x7::ArgumentError.new("Неверный формат телефона: #{phone}") unless new_phone
    res = ::Sms24x7::Base.sms_send(@session, phone, msg, opts)

    if reconnect?(res)

      self.login(@usr, @pass)
      res = self.message(@session, phone, msg, opts)

    end # if

    res

  end # message

  def state(mid)

    return ::Sms24x7::InactiveError.new("Отправка смс отключена") unless self.active?

    res = ::Sms24x7::Base.sms_state(@session, mid)

    if reconnect?(res)

      self.login(@usr, @pass)
      res = self.state(@session, mid)

    end # if

    res

  end # state

  def balance

    return ::Sms24x7::InactiveError.new("Отправка смс отключена") unless self.active?

    res = ::Sms24x7::Base.balance(@session)

    if reconnect?(res)

      self.login(@usr, @pass)
      res = self.balance(@session)

    end # if

    res

  end # balance

  def time

    return ::Sms24x7::InactiveError.new("Отправка смс отключена") unless self.active?

    res = ::Sms24x7::Base.time(@session)

    if reconnect?(res)

      self.login(@usr, @pass)
      res = self.time(@session)

    end # if

    res

  end # time

  def info

    return ::Sms24x7::InactiveError.new("Отправка смс отключена") unless self.active?

    res = ::Sms24x7::Base.info(@session)

    if reconnect?(res)

      self.login(@usr, @pass)
      res = self.info(@session)

    end # if

    res

  end # info

  def logout

    return ::Sms24x7::InactiveError.new("Отправка смс отключена") unless self.active?

    ::Sms24x7::Base.session_close(@session)
    @session = nil

    true

  end # logout

  def error?(e)
    e.is_a?(::Sms24x7::Error)
  end # error?

  def turn_on

    @active = true
    puts "[Sms24x7] Отправка SMS ВКЛЮЧЕНА"
    self

  end # turn_on

  def turn_off

    @active = false
    puts "[Sms24x7] Отправка SMS ОТКЛЮЧЕНА"
    self

  end # turn_off

  def debug_on

    @debug = true
    puts "[Sms24x7] Отладочный режим ВКЛЮЧЕН"
    self

  end # debug_on

  def debug_off

    @debug = false
    puts "[Sms24x7] Отладочный режим ОТКЛЮЧЕН"
    self

  end # debug_off

  def debug?
    @debug === true
  end # debug?

  def active?
    @active != false
  end # active?

  def valid_phone?(phone)
    !(phone.to_s.gsub(/\D/, "") =~ ::Sms24x7::PHONE_RE).nil?
  end # valid_phone?

  def convert_phone(phone, prefix = "7")

    r = phone.to_s.gsub(/\D/, "").scan(::Sms24x7::PHONE_RE)
    r.empty? ? nil : "#{prefix}#{r.last.last}"

  end # convert_phone

  private

  def reconnect?(res)
    res.is_a?(::Sms24x7::SessionExpiredError) || res.is_a?(::Sms24x7::AuthError)
  end # reconnect?

end # Sms24x7

require "sms24x7/base"
require "sms24x7/respond"
