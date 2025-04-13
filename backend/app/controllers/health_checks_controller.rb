# frozen_string_literal: true

class HealthChecksController < ApplicationController
  def index
    render json: { message: "Hello! It's #{Time.zone.now} now." }
  end
end
