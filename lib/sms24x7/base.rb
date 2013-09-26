# encoding: utf-8
module Sms24x7

  module Base

    extend self

    def sessionid(usr, pass)

      r = params_for({

        :method   => 'login',
        :email    => usr,
        :password => pass,
        :api_v    => 1.1

      })

      data  = {}
      err   = block_run do |http|

        log("[sessionid] => #{r}")

        res = request do
          http.post("/", r)
        end

        log("[sessionid] <= #{r} \n\r#{res.body}")

        data = ::Sms24x7::Respond.sessionid(res.body)

      end # block_run

      err || data

    end # sessionid

    def sms_send(session, phone, msg, opts = {})

      r = params_for({

        :method   => 'push_msg',
        :text     => msg,
        :phone    => phone,
        :sender_name => ::Sms24x7::TITLE_SMS,
        :type     => opts[:type] || "SMS",
        :validity => opts[:validity],
        :postpone => opts[:postpone],
        :api_v    => 1.1

      })

      data  = {}
      err   = block_run do |http|

        log("[sms_send] => #{r}")

        res = request do

          headers   = {}
          headers["Cookie"] = session if session

          http.post("/", r, headers)

        end

        log("[sms_send] <= #{r} \n\r#{res.body}")

        data = ::Sms24x7::Respond.sms_send(res.body)

      end # block_run

      err || data

    end # sms_send

    def sms_state(session, mid)

      r = params_for({

        :method   => 'get_msg_report',
        :id       => mid,
        :api_v    => 1.1

      })

      data  = {}
      err   = block_run do |http|

        log("[sms_state] => #{r}")

        res = request do

          headers   = {}
          headers["Cookie"] = session if session

          http.post("/", r, headers)

        end

        log("[sms_state] <= #{r} \n\r#{res.body}")

        data = ::Sms24x7::Respond.sms_state(res.body)

      end # block_run

      err || data

    end # sms_state

    def balance(session)

      r = params_for({

        :method   => 'get_profile',
        :api_v    => 1.1

      })

      data  = {}
      err   = block_run do |http|

        log("[balance] =>")

        res = request do

          headers   = {}
          headers["Cookie"] = session if session

          http.post("/", r, headers)

        end

        log("[balance] <= \n\r#{res.body}")

        data = ::Sms24x7::Respond.balance(res.body)

      end # block_run

      err || data

    end # balance

    def time(session)

      r = params_for({

        :method   => 'get_profile',
        :api_v    => 1.1

      })

      data  = {}
      err   = block_run do |http|

        log("[time] =>")

        res = request do

          headers   = {}
          headers["Cookie"] = session if session

          http.post("/", r, headers)

        end

        log("[time] <= \n\r#{res.body}")

        data = ::Sms24x7::Respond.time(res.body)

      end # block_run

      err || data

    end # time

    def info(session)

      r = params_for({

        :method   => 'get_profile',
        :api_v    => 1.1

      })

      data  = {}
      err   = block_run do |http|

        log("[info] =>")

        res = request do

          headers   = {}
          headers["Cookie"] = session if session

          http.post("/", r, headers)

        end

        log("[info] <= \n\r#{res.body}")

        data = ::Sms24x7::Respond.info(res.body)

      end # block_run

      err || data

    end # info

    def session_close(session)

      r = params_for({

        :method   => 'logout',
        :api_v    => 1.1

      })

      data  = {}
      err   = block_run do |http|

        log("[session_close] =>")

        res = request do

          headers   = {}
          headers["Cookie"] = session if session

          http.post("/", r, headers)

        end

        log("[session_close] <= \n\r#{res.body}")

        data = ::Sms24x7::Respond.session_close(res.body)

      end # block_run

      err || data

    end # session_close

    private

    def log(msg)

      puts(msg) if ::Sms24x7.debug?
      self

    end # log

    def params_for(params)

      params[:format] = 'json'
      params.delete_if { |key, v| v.nil? }

      ::URI.encode_www_form(params)

    end # params_for

    def block_run

      error     = false
      try_count = ::Sms24x7::RETRY

      begin

        ::Timeout::timeout(::Sms24x7::TIMEOUT) {

          ::Net::HTTP.start(
            ::Sms24x7::HOST,
            ::Sms24x7::PORT,
            :use_ssl => ::Sms24x7::USE_SSL
          ) do |http|
            yield(http)
          end

        }

      rescue ::Errno::ECONNREFUSED

        if try_count > 0
          try_count -= 1
          sleep ::Sms24x7::WAIT_TIME
          retry
        else
          error = ::Sms24x7::ConnectionError.new("Прервано соедиение с сервером")
        end

      rescue ::Timeout::Error

        if try_count > 0
          try_count -= 1
          sleep ::Sms24x7::WAIT_TIME
          retry
        else
          error = ::Sms24x7::TimeoutError.new("Превышен интервал ожидания #{::Sms24x7::TIMEOUT} сек. после #{::Sms24x7::RETRY} попыток")
        end

      rescue => e
        error = ::Sms24x7::UnknownError.new(e.message)
      end

      error

    end # block_run

    def request

      try_count = ::Sms24x7::RETRY

      res = yield
      while(try_count > 0 && res.code.to_i >= 300)

        log("[retry] #{try_count}. Wait #{::Sms24x7::WAIT_TIME} sec.")

        res = yield
        try_count -= 1
        sleep ::Sms24x7::WAIT_TIME

      end # while

      res

    end # request

  end # Base

end # Sms24x7
