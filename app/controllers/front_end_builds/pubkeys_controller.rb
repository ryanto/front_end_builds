require_dependency "front_end_builds/application_controller"

module FrontEndBuilds
  class PubkeysController < ApplicationController
    def index
      keys = FrontEndBuilds::Pubkey.order(:name)
      respond_with_json(pubkeys: keys.map(&:serialize))
    end

    def create
      pubkey = FrontEndBuilds::Pubkey
        .new( use_params(:pubkey_create_params) )

      if pubkey.save
        respond_with_json(
          { pubkey: pubkey.serialize },
          location: nil
        )
      else
        error!(pubkey.errors)
      end
    end

    def destroy
      pubkey = FrontEndBuilds::Pubkey.find(params[:id])

      if pubkey.destroy
        respond_with_json(
          { pubkey: { id: pubkey.id } },
          location: nil
        )
      else
        error!(pubkey.errors)
      end
    end

    private

    def pubkey_create_params_rails_3
      params[:pubkey].slice(:name, :pubkey)
    end

    def pubkey_create_params_rails_4
      params.require(:pubkey).permit(
        :name,
        :pubkey
      )
    end

    alias_method :pubkey_create_params_rails_5, :pubkey_create_params_rails_4
  end
end
