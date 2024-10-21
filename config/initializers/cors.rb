Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:8000', '127.0.0.1:8000', 'https://be-happy-front.vercel.app'

    resource '/api/*',
      headers: :any,
      methods: :any,
      expose: %w(Authorization),
      max_age: 600
  end
end
