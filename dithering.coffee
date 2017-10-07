module.exports = ->
  sierraKernel = [0.5, 0.25, 0.25]
  sierra = (errors, error, index, width) ->
    [r, g, b] = error
    k = sierraKernel

    [1, width - 1, width].forEach (n, z) ->
      i = (index + n) * 4
      c = k[z]

      errors[i] += r * c
      errors[i + 1] += g * c
      errors[i + 2] += b * c

    return

  atkinson = (errors, error, index, width) ->
    r = error[0] >> 3
    g = error[1] >> 3
    b = error[2] >> 3

    [1, 2, width - 1, width, width + 1, 2 * width].forEach (n) ->
      i = (index + n) * 4
      errors[i] += r
      errors[i + 1] += g
      errors[i + 2] += b

    return

  floydSteinbergKernel = [7, 3, 5, 1].map (n) -> n / 16
  floydSteinberg = (errors, error, index, width) ->
    [r, g, b] = error

    k = floydSteinbergKernel

    [1, width - 1, width, width + 1].forEach (n, z) ->
      i = (index + n) * 4

      c = k[z]

      errors[i] += r * c
      errors[i + 1] += g * c
      errors[i + 2] += b * c

    return

  atkinson: atkinson
  floydSteinberg: floydSteinberg
  sierra: sierra
