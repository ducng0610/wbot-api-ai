class WebviewController < ApplicationController
  def locations
    @locations = KnownLocation.where(type: 'location').map { |kl| kl.name.capitalize }
  end

  def current_weather
    location = params[:location]
    @current_weather = WeatherService.search_forecast(location)
  end
end
