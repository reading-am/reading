// From: https://github.com/ianoxley/encdec

function encdec(alphabet) {
    var BASE_58 = '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ';

    alphabet = alphabet || BASE_58;
    var baseCount = alphabet.length;
    var cache = {};

    return {
        encode : function(num) {
            if (isNaN(num)) {
                return '';
            }

            num = parseInt(num, 10);
            if (num < 0) {
                return '';
            }

            if (cache[num]) {
                return cache[num];
            }

      var encode = '';

          while (num >= baseCount) {
              var mod = num % baseCount;
              encode = alphabet[mod] + encode;
              num = parseInt(num / baseCount, 10);
          }

          if (num) {
              encode = alphabet[num] + encode;
          }

            cache[num] = encode;
          return encode;
        },

        decode : function(s) {
            if (typeof s !== 'string') {
                return 0;
            }

            if (cache[s]) {
                return cache[s];
            }

      var decoded = 0,
              multi = 1,
                s = s.split('').reverse().join('');

          for (var i = 0, max = s.length; i < max; i++) {
              decoded += multi * alphabet.indexOf(s[i]);
              multi = multi * baseCount;
          }

            cache[s] = decoded;
          return decoded;
        }
    };
}
