module MultipleNumericOptionsGenerator

using Random
using Decimals

export print_options
export print_cloze_options

function round_answer(ans, digits)
  if digits == 0
    return round(Int, ans)
  else
    return round(ans, digits = digits)
  end
end

function generate_random_answers_relative(ans, tolerance; nb_options = 5, rng = rng)
  tolerance = tolerance * 1.2
  step = 0.0000001
  while (ans * step <= tolerance)
    step *= 10
  end
  range_begin = ans * (1 - ((nb_options - 1) * step))
  range_end = ans * (1 + ((nb_options - 1) * step))
  potential_range = collect(range(range_begin, range_end, (nb_options-1) * 2 + 1))
  start = rand(rng, 1:nb_options)
  decimals = ceil(Int,log(10,1/tolerance))
  answers = [round_answer(potential_range[i], decimals) for i in start:start+(nb_options - 1)]
  correct_answer = nb_options + 1 - start
  return (answers, correct_answer)
end

function generate_random_answers_absolute(ans, delta; nb_options = 5, rng = rng)
  decimals = needed_decimals(ans, delta)
  range_begin = round(ans - ((nb_options - 1) * delta), digits = decimals)
  range_end = round(ans + ((nb_options - 1) * delta), digits = decimals)
  potential_range = collect(range_begin:delta:range_end)
  start = rand(rng, 1:nb_options)
  answers = [round_answer(potential_range[i], decimals) for i in start:start+(nb_options - 1)]
  correct_answer = nb_options + 1 - start
  return (answers, correct_answer)
end

function needed_decimals(ans, delta)
  tmp_ans = count_decimals(ans)
  tmp_delta = floor(Int, log(10, delta))
  if tmp_delta < 0
    tmp_delta = -tmp_delta
  else
    tmp_delta = 0
  end
  return max(tmp_ans, tmp_delta)
end

function print_options(ans, tolerance_or_delta, nb_options; mode = :absolute, rng = -1, unit = "", no_valid_answer = "")
  if rng == -1
    rng = MersenneTwister(rand(Int64));
  end
  alphabet = collect('a':'z')
  if mode == :relative
    (options, correct_answer) = generate_random_answers_relative(ans, tolerance_or_delta, nb_options = nb_options, rng = rng)
  else
    (options, correct_answer) = generate_random_answers_absolute(ans, tolerance_or_delta, nb_options = nb_options, rng = rng)
  end
  for i in 1:nb_options
      println((i==correct_answer ? "*" : "") * alphabet[i] * ") " * "$(options[i])" * unit)
  end
  if no_valid_answer != ""
    println("z) " * no_valid_answer)
  end
end

function print_invalid_options(ans, tolerance_or_delta, nb_options; mode = :absolute, rng = -1, unit = "")
  if rng == -1
    rng = MersenneTwister(rand(Int64));
  end
  alphabet = collect('a':'z')
  if mode == :relative
    (options, correct_answer) = generate_random_answers_relative(ans, tolerance_or_delta, nb_options = nb_options, rng = rng)
  else
    (options, correct_answer) = generate_random_answers_absolute(ans, tolerance_or_delta, nb_options = nb_options, rng = rng)
  end
  for i in 1:nb_options
      println(alphabet[i] * ") " * "$(options[i])" * unit)
  end
end

function count_decimals(x)
  return -Decimal(x).q
end

function print_cloze_options(ans, tolerance_or_delta, nb_options; mode = :absolute, rng = -1, unit = "", no_valid_answer = "")
  if rng == -1
    rng = MersenneTwister(rand(Int64));
  end
  alphabet = collect('a':'z')
  if mode == :relative
    (options, correct_answer) = generate_random_answers_relative(ans, tolerance_or_delta, nb_options = nb_options, rng = rng)
  else
    (options, correct_answer) = generate_random_answers_absolute(ans, tolerance_or_delta, nb_options = nb_options, rng = rng)
  end
  str = "{1:MULTICHOICE_VS:"
  for i in 1:nb_options
    if i > 1
      str *= "~"
    end
    if i==correct_answer
      str *= "="
    end
    str *= "$(options[i])" * unit
  end
  
  if no_valid_answer != ""
    str *= no_valid_answer
  end
  str *= "}"
end


end # module MultipleNumericOptionsGenerator

#{1:MULTICHOICE_VS:=6.01%~5.91%~6.11%~6.21%~6.31%~6.41%}