class SearchIndexJob
  include SuckerPunch::Job
  workers 4

  def perform action, obj
    case action.to_s
    when /create/
      obj.__elasticsearch__.index_document
    when /update/
      obj.__elasticsearch__.update_document
    when /destroy/
      obj.__elasticsearch__.delete_document
    else raise ArgumentError, "Unknown action '#{action}'"
    end
  end
end
