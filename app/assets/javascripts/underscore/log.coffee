_.mixin
  log: -> console.log.apply console, arguments if console? and console.log?
