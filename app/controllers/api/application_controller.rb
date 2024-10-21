module Api
  class ApplicationController < ::ApplicationController
    def options
      head :ok
    end
  end
end
