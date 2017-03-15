module Api
  module V2
    module Entities
      class ErrorResponse < BaseResponse

        expose :ok
        expose :type        
        expose :code, documentation: {type: String, desc: "error code", required: true}
        expose :errors, documentation: {type: Array, desc: ""}
        expose :status, documentation: {type: Integer, desc: "Http status code"}
        expose :trace, if: lambda { |status, options| Rails.env.development? }

        def self.factory(e, opts = {})
          eclass = e.class.to_s

          detail = e.message
          message = "Authentication error: #{e.to_s}" if eclass.match('WineBouncer::Errors')

          opts = {}
          opts[:error] = e.class.to_s.demodulize.underscore
          opts[:detail] = detail if detail.present?

          if Rails.env.development?
            opts[:trace] = e.backtrace[0,20] unless Rails.env.production?
            ExceptionNotifier.notify_exception(e)
          end

          entity = case 
          when eclass.match('OAuthUnauthorizedError')
            self.new(exception: e, status: 401, code: "invalid_grant")
          when eclass.match('Api::V2::Authorization::UnauthorizedException')
            self.new(exception: e, status: 401, code: "unauthorized")
          when eclass.match('OAuthForbiddenError')
            self.new(exception: e, status: 403, code: "forbidden_error")
          when eclass.match('RecordNotFound'), e.message.match(/unable to find/i).present?
            self.new(exception: e, status: 404, code: "record_not_found", message: "Could not find record")
          when eclass.match('RecordInvalid')
            ValidationError.new(exception: e, status: 422, code: "record_invalid")
          else
            status = (e.respond_to? :status) && e.status || 500
            opts[:exception] ||= e
            new(opts.merge(status: status))
          end

          return entity
        end

        def code
          return @code if @code.present?
          err_klass = self.exception.class
          err_klass.to_s.demodulize.underscore
        end

        def errors
          [@exception.present? ? @exception.message : (Rails.env.production? ? "Could not complete this request" : self.object)]
        end

        def status
          @status
        end

        def exception
          @exception
        end

        def type
          "Error"
        end

        def ok
          "error"
        end

        def initialize(opts = {})
          @exception = opts.delete(:exception)
          @status = opts.delete(:status)
          @code = opts.delete(:code)
          super(opts)
        end

      end
    end
  end
end
