reading.define ["libs/lodash"], (_) ->

  _.mixin
    ISODateString: (d) ->
      if d.toISOString
        d.toISOString()
      else
        pad = (n) -> if n<10 then "0#{n}" else n
        "#{d.getUTCFullYear()}-#{pad(d.getUTCMonth()+1)}-#{pad(d.getUTCDate())}T#{pad(d.getUTCHours())}:#{pad(d.getUTCMinutes())}:#{pad(d.getUTCSeconds())}Z"

  return _
