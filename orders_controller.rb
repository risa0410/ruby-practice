class Public::OrdersController < ApplicationController

  def index
    @orders = current_customer.orders.page(params[:page]).per(5).order(created_at: :desc)
    @product = Product.all
    # @page = Order.page(params[:page]).per(10)
  end

  def show
    @order = Order.find(params[:id])
    @ordered_products = @order.ordered_products
    @order.carriage = 800
  end

  def new
    @order = Order.new
    @address = current_customer
    @receiver = current_customer.receivers.all
  end

  def comfirm
    @cart_items = current_customer.cart_items
    @address_option = params[:order][:address_option]

    @order =Order.new
    @order.payment_method = params[:order][:payment_method]
    @order.carriage = 800
    if @address_option == "0"
      @order.address = current_customer.address
      @order.postal_code = current_customer.postal_code
      @order.name = current_customer.first_name
    elsif @address_option == "1"
      # @saved_address = Receiver.find_by(order_params[:order_address])
      # @saved_address = Receiver.find_by(id: params[:order][:order_address])
      @receiver = Receiver.find(params[:order][:order_address])
      @order.address = @receiver.address
      @order.postal_code = @receiver.postal_code
      @order.name = @receiver.name

    elsif @address_option == "2"

      @order.postal_code = params[:order][:postal_code]
      @order.address = params[:order][:address]
      @order.name = params[:order][:name]
    end
  end

  def create
    @order = Order.new(order_params)
    @order.customer_id = current_customer.id
    @order.carriage = 800
    @order.status = 0

    @cart_items = current_customer.cart_items
    @product = Product.all
    @cart_items.each do |cart_item|
      @ordered_products = @order.ordered_products.new
      @ordered_products.product_id = cart_item.product.id
      @ordered_products.amount = cart_item.amount
      @ordered_products.making_status = 0
      @ordered_products.price = cart_item.product.add_tax_price
      @ordered_products.save
    end
      current_customer.cart_items.destroy_all

    if @order.save
      redirect_to orders_complete_path
    else
      redirect_to orders_comfirm_path
    end
  end

  def complete
  end

  private
    def order_params
      params.require(:order).permit(:postal_code, :address, :name, :payment_method, :total_payment)
    end

end
