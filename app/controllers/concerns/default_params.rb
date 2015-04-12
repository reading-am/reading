module DefaultParams
  extend ActiveSupport::Concern

  included do
    before_action :set_default_params
  end
  
  def set_default_params
    # [lower_bound, (param || default), upper_bound]
    params[:limit]  = [1, (params[:limit] || 20).to_i, 200].sort[1]

    params[:offset] = params[:offset].to_i

    # Limit arrays of ids to 100 at a time
    params.each { |k,v| params[k] = params[k][0..99] if params[k].kind_of?(Array) }
  end
end
