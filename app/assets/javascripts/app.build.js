({
  baseUrl: ".",
  name: 'application',
  out: 'application_built.js',
  packages: {
    app: {
      path: "backbone",
      main: "reading"
    },
    extend: {
      path: "libs/extend"
    },
    plugins: {
      name: "plugins",
      path: "jquery"
    }
  },
  paths: {
    jquery:     "libs/jquery",
    jquery_ui:  "libs/jquery_ui",
    underscore: "libs/lodash_extended",
    backbone:   "libs/backbone_extended",
    handlebars: "libs/handlebars_extended"
  }
})
