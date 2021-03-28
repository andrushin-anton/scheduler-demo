class OrdersController < ApplicationController
  # GET /orders
  # GET /orders.json
  def index
    authorize! :index, Orders

    @search = params[:search]
    @orders = Orders.search(params[:search], params[:page])
  end
end
