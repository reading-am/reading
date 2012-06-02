# From: https://github.com/ianoxley/encdec
# translated at: http://js2coffee.org

reading.define ->

  encdec = (alphabet) ->
    BASE_58 = "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
    alphabet = alphabet or BASE_58
    baseCount = alphabet.length
    cache = {}
    encode: (num) ->
      return "" if isNaN(num)
      num = parseInt(num, 10)
      return "" if num < 0
      return cache[num] if cache[num]
      encode = ""
      while num >= baseCount
        mod = num % baseCount
        encode = alphabet[mod] + encode
        num = parseInt(num / baseCount, 10)
      encode = alphabet[num] + encode  if num
      cache[num] = encode
      encode

    decode: (s) ->
      return 0 if typeof s isnt "string"
      return cache[s] if cache[s]
      decoded = 0
      multi = 1
      s = s.split("").reverse().join("")
      i = 0
      max = s.length

      while i < max
        decoded += multi * alphabet.indexOf(s[i])
        multi = multi * baseCount
        i++
      cache[s] = decoded
      decoded

  return encdec()
