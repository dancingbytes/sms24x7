# encoding: utf-8
module Sms24x7

  module Respond

    extend self

    def sessionid(body)

      r = answer(body)
      return r if ::Sms24x7.error?(r)
      r["sid"]

    end # sessionid

    def sms_send(body)

      r = answer(body)
      return r if ::Sms24x7.error?(r)

      {
        id_sms: r["id"],
        parts:  r["n_raw_sms"]
      }

    end # sms_send

    def sms_state(body)

      r = answer(body)
      return r if ::Sms24x7.error?(r)

      {
        time:     r["last_update"],
        state:    r["state"].to_i
      }

    end # sms_state

    def balance(body)

      r = answer(body)
      return r if ::Sms24x7.error?(r)
      r["credits"]

    end # balance

    def time(body)

      r = answer(body)
      return r if ::Sms24x7.error?(r)
      r["local_time"]

    end # time

    def info(body)

      r = answer(body)
      return r if ::Sms24x7.error?(r)
      r.inject({}) {|memo,(k,v)| memo[k.to_sym] = v; memo }

    end # info

    def session_close(body)

      r = answer(body)
      return r if ::Sms24x7.error?(r)
      r

    end # session_close

    private

    def answer(body)

      res = ::JSON.parse(body) rescue ::Sms24x7::RespondError.new("Неверный ответ сервера: #{body}")
      return res if ::Sms24x7.error?(res)

      r = res["response"] || {}
      return ::Sms24x7::RespondError.new("Неверный формат ответа: #{res}") if r.empty?

      m = r["msg"] || {}
      return ::Sms24x7::RespondError.new("Неверный формат ответа: #{res}") if m.empty?

      if (code = (m["err_code"] || 0).to_i) > 0

        return case code

          when 18 then  ::Sms24x7::SessionExpiredError.new(m["text"])
          when 42 then  ::Sms24x7::AuthError.new(m["text"])
          else          ::Sms24x7::RespondError.new(m["text"])

        end # case

      end # if

      r["data"] || {}

    end # answer

  end # Respond

end # Sms24x7
