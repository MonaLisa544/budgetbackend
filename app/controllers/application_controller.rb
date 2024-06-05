class ApplicationController < ActionController::API
    include JwtHelper

    before_action :authorize_request
end
