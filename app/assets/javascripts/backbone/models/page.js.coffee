class Reading.Models.Page extends Backbone.Model
  paramRoot: 'page'

class Reading.Collections.PagesCollection extends Backbone.Collection
  model: Reading.Models.Page
  url: '/pages'
