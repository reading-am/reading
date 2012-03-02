// from: https://github.com/twitter/bootstrap/pull/1821

$.fn.tooltip.Constructor.prototype.enter = function ( e ) {
  var self = $(e.currentTarget)[this.type](this._options).data(this.type)

  if (!self.options.delay || !self.options.delay.show) {
    self.show()
  } else {
    self.hoverState = 'in'
    self.delayedShow = setTimeout(function() {
      if (self.hoverState == 'in') {
        self.show()
        self.delayedShow = undefined
      }
    }, self.options.delay.show)
  }
}

$.fn.tooltip.Constructor.prototype.leave = function ( e ) {
  var self = $(e.currentTarget)[this.type](this._options).data(this.type)

  if (self.delayedShow) {
    clearTimeout(self.delayedShow)
    return
  }

  if (!self.options.delay || !self.options.delay.hide) {
    self.hide()
  } else {
    self.hoverState = 'out'
    setTimeout(function() {
      if (self.hoverState == 'out') {
        self.hide()
      }
    }, self.options.delay.hide)
  }
}
