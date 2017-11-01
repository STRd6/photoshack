# Extend promises with `finally`
# From: https://github.com/domenic/promises-unwrapping/issues/18
Promise.prototype.finally ?= (callback) ->
  # We don’t invoke the callback in here,
  # because we want then() to handle its exceptions
  this.then(
    # Callback fulfills: pass on predecessor settlement
    # Callback rejects: pass on rejection (=omit 2nd arg.)
    (value) ->
      Promise.resolve(callback())
      .then -> return value
    (reason) ->
      Promise.resolve(callback())
      .then -> throw reason
  )
