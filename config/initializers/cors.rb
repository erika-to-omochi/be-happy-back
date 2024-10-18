Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:8000', '127.0.0.1:8000', 'https://be-happy-front.vercel.app'

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization']
  end
end
