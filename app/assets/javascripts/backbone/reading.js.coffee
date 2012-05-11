#= require_self
#= require_tree ./addons
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.ø =
  $: jQuery.noConflict()
  _: _.noConflict()
  Backbone: Backbone.noConflict()
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
