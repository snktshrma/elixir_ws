defmodule Testing do

@vals_y %{a: 1, b: 2, c: 3, d: 4, e: 5}

	def fort(list,n,start,last,fin, ind) when ind == n-1 do
		x = Enum.at(list,ind)
		x = List.insert_at(x,0,start)
		nx = length(x)
		last = forx(x,nx,last,fin)
		IO.inspect last
		IO.inspect list
		IO.inspect Enum.at(list,Enum.find_index(last, fn x -> x == Enum.min(last) end))
	end

	def fory(x,nx,inx,last,fin,ind) when ind == nx-1 do
		fin = List.insert_at(fin,-1,subt(Enum.at(x,inx),Enum.at(x,ind)))
	end




	def fort(list,n,start,last \\ [],fin \\ [],ind \\ 0) do
		x = Enum.at(list,ind)
		x = List.insert_at(x,0,start)
		nx = length(x)
		last = forx(x,nx,last,fin)

		fort(list,n,start,last,fin,ind+1)
	end

	def forx(x,nx,last,fin,ind \\ 0) do

		fin = fory(x,nx,ind,last,fin)

		List.insert_at(last,-1,Enum.sum(fin))
	end

	def fory(x,nx,inx,last,fin,ind \\ 0) do

		fin = List.insert_at(fin,-1,subt(Enum.at(x,inx),Enum.at(x,ind)))
		inx = ind
		fory(x,nx,inx,last,fin,ind+1)
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
		start = [1,:a]
		list = of([[3,:c],[4,:a],[2,:e]])
		n = length(list)

		fort(list,n,start)

	end


end


