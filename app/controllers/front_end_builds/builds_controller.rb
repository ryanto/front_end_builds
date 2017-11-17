require_dependency "front_end_builds/application_controller"

module FrontEndBuilds
  class BuildsController < ApplicationController
    if Rails::VERSION::MAJOR > 4
      before_action :set_app!, only: [:create]
    else
      before_filter :set_app!, only: [:create]
    end

    def index
      builds = FrontEndBuilds::Build.where(app_id: params[:app_id])
      respond_with_json({
          builds: builds.map(&:serialize)
        })
    end

    def create
      build = @app.builds.new(use_params(:build_create_params))

      if build.verify && build.save
        build.setup!
        head :ok

      else
        build.errors[:base] << 'No access - invalid SSH key' if !build.verify

        render(
          plain: 'Could not create the build: ' + build.errors.full_messages.to_s,
          status: :unprocessable_entity
        )
      end
    end

    def show
      build = FrontEndBuilds::Build.find(params[:id])
      respond_with_json({
        build: build.serialize
      })
    end

    private

    def set_app!
      @app = FrontEndBuilds::App
        .where(name: params[:app_name])
        .limit(1)
        .first

      if @app.nil?
        render(
          plain: "No app named #{params[:app_name]}.",
          status: :unprocessable_entity
        )

        return false
      end
    end

    def _create_params
      [
        :branch,
        :sha,
        :job,
        :endpoint,
        :html,
        :signature
      ]
    end

    def build_create_params_rails_3
      params.slice(*_create_params)
    end

    def build_create_params_rails_4
      params.permit(*_create_params)
    end

    alias_method :build_create_params_rails_5, :build_create_params_rails_4
  end
end
