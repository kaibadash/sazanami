class Api::V1::HealthChecksController < ApplicationController
  def index
    render json: { message: "Hello! It's #{Time.now} now." }
  end
end
