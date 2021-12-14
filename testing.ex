defmodule Testing do

@vals_y %{a: 1, b: 2, c: 3, d: 4, e: 5}
@vals_facing %{north: 1, east: 2, south: 3, west: 4}

	def fort(list,n,start,bot,last,fin, ind) when ind == n-1 do
		x = Enum.at(list,ind)
		x = List.insert_at(x,0,[Enum.at(start,0),Enum.at(start,1)])
		nx = length(x)
		last = forx(x,nx,last,fin,Enum.at(start,2))
		list = for a <- list, do: for b <- a, do: List.insert_at(b,-1,bot)
		[Enum.min(last), Enum.at(list,Enum.find_index(last, fn x -> x == Enum.min(last) end))]
	end

	def fory(x,nx,inx,last,fin,face,ind) when ind == nx-1 do
		fin = List.insert_at(fin,-1,subt(Enum.at(x,inx),Enum.at(x,ind)))
		facing = face_error(Enum.at(Enum.at(x,inx),0), Enum.at(Enum.at(x,inx),1), Enum.at(Enum.at(x,ind),0), Enum.at(Enum.at(x,ind),1), face)
		sum = abs(Enum.at(facing,0)) + abs(Enum.at(facing,1))
		fin = List.insert_at(fin,-1,sum)
		
	end




	def fort(list,n,start,bot,last \\ [],fin \\ [],ind \\ 0) do
		x = Enum.at(list,ind)
		x = List.insert_at(x,0,[Enum.at(start,0),Enum.at(start,1)])
		nx = length(x)
		last = forx(x,nx,last,fin,Enum.at(start,2))

		fort(list,n,start,bot,last,fin,ind+1)
	end

	def forx(x,nx,last,fin,face,ind \\ 0) do


		fin = fory(x,nx,ind,last,fin,face)

		List.insert_at(last,-1,Enum.sum(fin))
	end

	def fory(x,nx,inx,last,fin,face,ind \\ 0) do

		fin = List.insert_at(fin,-1,subt(Enum.at(x,inx),Enum.at(x,ind)))
		facing = face_error(Enum.at(Enum.at(x,inx),0), Enum.at(Enum.at(x,inx),1), Enum.at(Enum.at(x,ind),0), Enum.at(Enum.at(x,ind),1), face)
		sum = abs(Enum.at(facing,0)) + abs(Enum.at(facing,1))
		fin = List.insert_at(fin,-1,sum)
		inx = ind

		sum2 = -Enum.at(facing,0) - Enum.at(facing,1)
		facen = @vals_facing[face] + sum2

		facen  = cond do

					facen > 4 -> facen - 4
					facen < 1 -> facen + 4
					true -> facen
				 end

		face = cond do
					facen == 1 -> :north
					facen == 2 -> :east
					facen == 3 -> :south
					facen == 4 -> :west
			   end
		fory(x,nx,inx,last,fin,face,ind+1)
	end

	def subt(a,b) do

		new = []
		x1 = Enum.at(a,0)
		x2 = Enum.at(b,0)
		y1 = Enum.at(a,1)
		y2 = Enum.at(b,1)
		y1 = @vals_y[y1]
		y2 = @vals_y[y2]
		x = abs(x1-x2)
		y = abs(y1-y2)
		new = List.insert_at(new,-1,x)
		new = List.insert_at(new,-1,y)
		Enum.sum(new)

	end

	

	def of([]) do
	  [[]]
	end

	def of(list) do
	  for h <- list, t <- of(list -- [h]), do: [h | t]
	end



	def arrange() do
		start = [1,:a,:north]
		list = of([[1,:c],[4,:c],[3,:b],[3,:e]])
		n = length(list)

		aa = Enum.at(fort(list,n,start,"a"),1)

		bb = Enum.at(fort(list,n,[5,:e,:south],"b"),1)

		st = aa ++ bb
		main(st,length(aa))
	end


	def without_repetitions([], _k), do: [[]]


	def without_repetitions(_list, 0), do: [[]]


	def without_repetitions(list, k) do
  		for head <- list, tail <- without_repetitions(list -- [head], k - 1), do: [head | tail]
	end



	def main(list,k,fii,mn,ind, rep) when ind == length(list) - 1 do

		x = Enum.at(list,ind)
		eA = for a <- x, Enum.at(a,2) == "a", do: List.delete_at(a,2)
		eB = for a <- x, Enum.at(a,2) == "b", do: List.delete_at(a,2)



		listA = of(eA)
		listB = of(eB)

		aa = fort(listA,length(listA),[1,:a,:north],"a")
		bb = fort(listB,length(listB),[5,:e,:south],"b")
		sumAB = Enum.at(aa,0) + Enum.at(bb,0)
		last = List.insert_at(mn,-1,sumAB)
		fii = List.insert_at(fii,-1,Enum.at(aa,1) ++ Enum.at(bb,1))
		IO.inspect last
		IO.inspect fii
		Enum.at(fii,Enum.find_index(last, fn x -> x == Enum.min(last) end))

	end



	def main(list,k,fii \\ [], mn \\ [],ind \\ 0, rep \\ 0) do
		if rep == 0 do
			lis = without_repetitions(list,k)
			new = for x <- (for a <- lis, do: Enum.uniq_by(a, fn [l,m,_] -> {l,m} end)), length(x) == k, do: x
			unique = for g <- new, do: Enum.sort(g)
			final = Enum.uniq(unique)
			IO.inspect final
			main(final,k,fii,mn,ind, rep+1)

		else
			x = Enum.at(list,ind)
			eA = for a <- x, Enum.at(a,2) == "a", do: List.delete_at(a,2)
			eB = for a <- x, Enum.at(a,2) == "b", do: List.delete_at(a,2)
			listA = of(eA)
			listB = of(eB)
			
			aa = fort(listA,length(listA),[1,:a,:north],"a")

			bb = fort(listB,length(listB),[5,:e,:south],"b")

			sumAB = Enum.at(aa,0) + Enum.at(bb,0)

			mn = List.insert_at(mn,-1,sumAB)
			fii = List.insert_at(fii,-1,Enum.at(aa,1) ++ Enum.at(bb,1))

			sumAB
			main(list,k,fii,mn,ind+1,rep)

		end
	end
	

	def face_error(robot_x, robot_y, x, y, robot_facing) do

		goal_y = y
	    goal_x = x


	    error_x = goal_x - robot_x
	    error_y = @vals_y[goal_y] - @vals_y[robot_y]


		ab = cond do 
				error_y == 0 and error_x == 0 -> 0
				error_y != 0 ->
			        cond do
			          error_y > 0 and @vals_facing[robot_facing] == 4 -> -1

			          error_y > 0 -> 
			            err = @vals_facing[robot_facing] - 1 

			            cond do
			              err == 2 and error_x != 0 or err == -2 and error_x != 0 -> 
			                cond do
			                  error_x < 0 and @vals_facing[robot_facing] == 1 -> 1

			                  error_x > 0 -> 
			                    @vals_facing[robot_facing] - 2


			                  error_x < 0 ->
			                    @vals_facing[robot_facing] - 4
			                end
			              true -> err
			            end


			          error_y < 0 ->
			            err = @vals_facing[robot_facing] - 3

			            cond do
			              err == 2 and error_x != 0 or err == -2 and error_x != 0 -> 
			                cond do
			                  error_x < 0 and @vals_facing[robot_facing] == 1 -> 1

			                  error_x > 0 -> 
			                    @vals_facing[robot_facing] - 2 

			                  error_x < 0 ->
			                    @vals_facing[robot_facing] - 4
			                end
			              true -> err
			            end
			        end
			    true -> 0
			end


		ba = cond do
				error_y == 0 and error_x == 0 -> 0
				error_x != 0 ->
			        cond do
			          error_x < 0 and @vals_facing[robot_facing] == 1 -> 1

			          error_x > 0 -> 
			            err = @vals_facing[robot_facing] - 2

			            cond do
			              err == 2 and error_y != 0 or err == -2 and error_y != 0 -> 
			                cond do

			                  error_y > 0 and @vals_facing[robot_facing] == 4 -> -1

			                  error_y > 0 ->
			                    @vals_facing[robot_facing] - 1 

			                  error_y < 0 ->
			                    @vals_facing[robot_facing] - 3
			                end
			              true -> err
			            end

			                    
			          error_x < 0 ->
			            err = @vals_facing[robot_facing] - 4

			            cond do
			              err == 2 and error_y != 0 or err == -2 and error_y != 0 -> 
			                cond do
			                  error_y > 0 and @vals_facing[robot_facing] == 4 -> -1

			                  error_y > 0 ->
			                    @vals_facing[robot_facing] - 1 

			                  error_y < 0 ->
			                    @vals_facing[robot_facing] - 3

			                end
			              true -> err
			            end

			        end
			    true -> 0
			end

		[ab,ba]	
	end

end


