extend = (root, obj) ->
  for key, value of obj
    root[key] = value

  return exports

extend(exports, require('./socket'))
extend(exports, require('./promisify'))
extend(exports, require('./lines'))
