# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '6c84f55294403cb0b754c4d2cfb7d14f'
  
  SECRET = 'Monkeys like bananas in the early morning'
  BASE_URI = 'http://0.0.0.0:3001/'
end
