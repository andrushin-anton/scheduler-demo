class StatisticsController < ApplicationController
  def index
    authorize! :statistics, Statistics

    @statuses = Appointment.get_statuses
  end
end
