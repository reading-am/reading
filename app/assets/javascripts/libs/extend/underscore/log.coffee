define ["libs/lodash"], (_) ->

  _.mixin
    log: -> console.log.apply console, arguments if console? and console.log?

  return _
