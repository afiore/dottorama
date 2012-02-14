app.utils =
  # 
  # Iterative implementation of Function.prototype.apply
  #
  # Parameters:
  #
  # funcs   - The array of functions to be called
  # args    - The array of arguments to be applied as function arguments
  # binding - The value of this (optional)
  #
  #
  applyAll: (funcs, args, binding=null) =>
    _.each(funcs, (func) => 
      func.apply(binding or this, args)
    )
