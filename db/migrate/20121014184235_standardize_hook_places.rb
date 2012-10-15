class StandardizeHookPlaces < ActiveRecord::Migration
  def up
    Hook.where(:provider => Hook::PLACE_TYPES.keys).each do |hook|
      place_name = Hook::PLACE_TYPES[hook.provider]
      params = hook.params
      unless params[place_name].blank?
        params['place'] = {'id' => params[place_name], 'name' => params[place_name]}
        params.delete(place_name)
        hook.params = params.to_json
        hook.save
      end
    end
  end

  def down
    Hook.where(:provider => Hook::PLACE_TYPES.keys).each do |hook|
      place_name = Hook::PLACE_TYPES[hook.provider]
      params = hook.params
      unless params['place'].blank?
        params[place_name] = params['place']['id']
        params.delete('place')
        hook.params = params.to_json
        hook.save
      end
    end
  end
end
