# This is used in requirejs.yml group "web/init" so that all of the routers
# that are used in footer script tags will be available in the final build
# NOTE - this must list include ALL routers, which is a bummer manual task

require [
  "app/routers/comments"
  "app/routers/users"
  "app/routers/posts"
  "app/routers/hooks"
  "app/routers/admin"
  "app/routers/search"
], ->
