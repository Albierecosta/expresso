module Admin
  class BaseController < ApplicationController
    include Authenticatable
    include Authorizable
  end
end
