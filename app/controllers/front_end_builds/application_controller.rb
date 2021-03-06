module FrontEndBuilds
  class ApplicationController < ActionController::Base

    def use_params(param_method)
      v = Rails::VERSION::MAJOR
      send("#{param_method}_rails_#{v}")
    end

    # Public: A quick helper to create a respond_to block for
    # returning json to the client. Used because `respond_with`
    # is no longer included in Rails.
    def respond_with_json(object, options = {})
      respond_to do |format|
        format.json do
          render options.merge(json: object)
        end
      end
    end

    def error!(errors, status = :unprocessable_entity)
      respond_with_json({ errors: errors }, status: status)
    end

  end
end
