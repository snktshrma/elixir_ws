defmodule Test do

	def without_repetitions([], _k), do: [[]]


	def without_repetitions(_list, 0), do: [[]]


	def without_repetitions(list, k) do
  		for head <- list, tail <- without_repetitions(list -- [head], k - 1), 
    do: [head | tail]
	end

	def main(k) do
		lis = without_repetitions([[1,:c, "a"],[2,:d, "a"],[4,:b, "a"],[2,:d, "b"],[1,:c, "b"],[4,:b, "b"]],k)
		new = for x <- (for a <- lis, do: Enum.uniq_by(a, fn [l,m,_] -> {l,m} end)), length(x) == k, do: x
		unique = for g <- new, do: Enum.sort(g)
		final = Enum.uniq(unique)
	end

	# for a <- [[[1, :c, "a"], [3, :e, "b"], [4, :c, "a"]], [[1, :c, "a"], [3, :e, "b"], [4, :c, "a"]]], do: Tuple.to_list(Enum.split_with(a, fn [_,_,m] -> m == "a" end))   
	# for a <- [[[1, :c, "a"], [3, :e, "b"], [4, :c, "a"]], [[1, :c, "a"], [3, :e, "b"], [4, :c, "a"]]], do: Tuple.to_list(Enum.split_with(a, fn [_,_,m] -> m == "a" end))
	# for g <- (for a <- [[[1, :c, "a"], [3, :e, "b"], [4, :c, "a"]], [[1, :c, "a"], [3, :e, "b"], [4, :c, "a"]]], do: Tuple.to_list(Enum.split_with(a, fn [_,_,m] -> m == "a" end))), do: List.delete_at(g,-1)


end