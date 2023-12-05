class ClearcacheController < ApplicationController

  # Authentication is not required for these methods
  skip_before_action :require_auth, only: [:index]


  def index
    Rails.cache.clear
    render html: "<script>alert('Cache cleared Successfully!')</script>".html_safe
  end

end
