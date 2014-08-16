class ChargesController < ApplicationController

  def new
  end

  def create
    
    customer = Stripe::Customer.create(email: params[:stripeEmail],
                                       plan: 'one-dollar',
                                       quantity: 2 * 3, # billed 3 months at a time
                                       card: params[:stripeToken])

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end

end
