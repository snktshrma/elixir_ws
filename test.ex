defmodule Test do

	def subt(a,b) do
		new = []
		x1 = Enum.at(a,0)
		x2 = Enum.at(b,0)
		y1 = Enum.at(a,1)
		y2 = Enum.at(b,1)
		x = abs(x1-x2)
		y = abs(y1-y2)
		new = List.insert_at(new,-1,x)
		new = List.insert_at(new,-1,y)

	end
end