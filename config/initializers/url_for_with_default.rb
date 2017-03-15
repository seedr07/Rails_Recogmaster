#
# module UrlForWithDefault
# 
#   This module monkey patches url_for so that it mantains the params[:network]
#   if its present
#
# NOTE: currently this does not affect optimized routes.
#              See .rvm/gems/ruby-2.2.2/gems/actionpack-4.1.10/lib/action_dispatch/routing/route_set.rb:243 UrlHelper
module UrlForWithDefault
  def self.included(base)
    base.module_eval do
      alias_method_chain :url_for, :default
    end
    ActionDispatch::Http::URL.send(:extend, ActionDispatchPatch)
    class << ActionDispatch::Http::URL
      alias_method_chain :url_for, :default
    end
  end

  module ActionDispatchPatch
    def url_for_with_default(*args)
      viewer = args[0].delete("viewer") || args[0].delete(:viewer)
      referrer = args[0].delete("referrer") || args[0].delete(:referrer)
      args[0][:params] ||= {}
      args[0][:params][:viewer] = viewer if viewer.present?
      args[0][:params][:referrer] = referrer if referrer.present?
      url_for_without_default(args[0])
    end
  end

  def url_for_with_default(*args)
    if args[0].kind_of?(Hash)
      opts = args[0]

      if opts[:network].kind_of?(ActiveRecord::Base)
        obj = opts.delete(:network)
        
        # added to handle users links who may be in different subcompany
        # Eg, cross-sub-company recognitions
        opts[:network] = obj.network if obj.respond_to?(:network)

        if opts.has_key?(:id)
          opts[:id] = obj
        else
          # this handles nested resources
          obj_key = (obj.class.to_s.underscore+"_id").to_sym
          if opts.has_key?(obj_key)
            opts[obj_key] = obj
          end
        end

      end

      begin
        unless self.respond_to?(:message) && self.message.kind_of?(Mail::Message)
          opts[:viewer] = params['viewer'] || params[:viewer] if (defined?(params) || respond_to?(:params)) && params.present?
        end
      rescue => e
        debugger if Rails.env.development?
        raise e unless Rails.env.development?
      end


      begin
        url_for_without_default(opts)
      rescue ActionController::UrlGenerationError => e
        if obj.respond_to?(:network)
          opts[:network] = obj.network
          url_for_without_default(opts)
        elsif respond_to?(:current_user) && current_user && (!opts.has_key?(:network) || opts[:network].blank?)
          opts[:network] = current_user.network
          url_for_without_default(opts)
        else
          raise e
        end
      end
    end
    url_for_without_default(*args)
  end
end
ActionDispatch::Routing::UrlFor.send(:include, UrlForWithDefault)

