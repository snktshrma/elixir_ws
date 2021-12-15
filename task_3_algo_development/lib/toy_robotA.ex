defmodule CLI.ToyRobotA do
  # max x-coordinate of table top
  @table_top_x 5
  # max y-coordinate of table top
  @table_top_y :e
  # mapping of y-coordinates
  @robot_map_y_atom_to_num %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}

  @doc """
  Places the robot to the default position of (1, A, North)

  Examples:

      iex> CLI.ToyRobotA.place
      {:ok, %CLI.Position{facing: :north, x: 1, y: :a}}
  """
  def place do
    {:ok, %CLI.Position{}}
  end

  def place(x, y, _facing) when x < 1 or y < :a or x > @table_top_x or y > @table_top_y do
    {:failure, "Invalid position"}
  end

  def place(_x, _y, facing)
  when facing not in [:north, :east, :south, :west]
  do
    {:failure, "Invalid facing direction"}
  end

  @doc """
  Places the robot to the provided position of (x, y, facing),
  but prevents it to be placed outside of the table and facing invalid direction.

  Examples:

      iex> CLI.ToyRobotA.place(1, :b, :south)
      {:ok, %CLI.Position{facing: :south, x: 1, y: :b}}

      iex> CLI.ToyRobotA.place(-1, :f, :north)
      {:failure, "Invalid position"}

      iex> CLI.ToyRobotA.place(3, :c, :north_east)
      {:failure, "Invalid facing direction"}
  """
  def place(x, y, facing) do
    # IO.puts String.upcase("A I'm placed at => #{x},#{y},#{facing}")
    {:ok, %CLI.Position{x: x, y: y, facing: facing}}
  end

  @doc """
  Provide START position to the robot as given location of (x, y, facing) and place it.
  """
  def start(x, y, facing) do
    {:ok, %CLI.Position{x: x, y: y, facing: facing}}
  end

  def stop(_robot, goal_x, goal_y, _cli_proc_name) when goal_x < 1 or goal_y < :a or goal_x > @table_top_x or goal_y > @table_top_y do
    {:failure, "Invalid STOP position"}
  end

  @doc """
  Provide GOAL positions to the robot as given location of [(x1, y1),(x2, y2),..] and plan the path from START to these locations.
  Passing the CLI Server process name that will be used to send robot's current status after each action is taken.
  Spawn a process and register it with name ':client_toyrobotA' which is used by CLI Server to send an
  indication for the presence of obstacle ahead of robot's current position and facing.
  """

  @vals_facing %{north: 1, east: 2, south: 3, west: 4}
  @vals_y %{a: 1, b: 2, c: 3, d: 4, e: 5}

  def retest(robot) do
    x = robot.x
    y = @vals_y[robot.y]
    f = @vals_facing[robot.facing]
    cond do
      y == 1 and f == 4 -> -1
      y == 1 and f == 2-> 1
      y == 1 and f == 1-> 0
      y == 1 and f == 3-> 2
      x == 1 -> f - 2
      y == 5 -> f - 3
      x == 5 and f == 1 -> 1
      x == 5 and f == 3 -> -1
      x == 5 and f == 2 -> 2
      x == 5 and f == 4 -> 0
      true -> -1
    end
  end


def for_check(n,robot,t,erro,er,goal_locs) when n == 1 do
    [goal_x,goal_y] = val_ext(goal_locs)
    if t == 'r' do
      robot = right(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_locs)
      else
        for_loop(erro, robot, er,goal_locs)
      end
      
    else
      robot = left(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_locs)
      else
        for_loop(erro, robot, er,goal_locs)
      end
    end
  end



  def for_check(n,robot,t,erro, er,goal_locs) do
    [goal_x,goal_y] = val_ext(goal_locs)
    if t == 'r' do
      robot = right(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_locs)
      else
        for_check(n - 1, robot,t,erro,er,goal_locs)
      end
    else
      robot = left(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_locs)
      else
        for_check(n - 1, robot,t,erro,er,goal_locs)
      end
    end
  end


  def con_check(n,robot,erro,er,goal_locs) do 
    [goal_x,goal_y] = val_ext(goal_locs)
    cond do
      n >= 1 -> for_check(n,robot,'l',erro, er,goal_locs)
      n <= -1 -> for_check(n*(-1),robot,'r',erro, er,goal_locs)
      n==0 -> for_loop(erro, robot, er,goal_locs)
    end
  end



  def for_loop(n,robot,er,goal_locs) when n == 1 and er == 0 do
    [goal_x,goal_y] = val_ext(goal_locs)
    recA(robot)
    robot = move(robot)
    len = length(goal_locs)
    num = List.last(goal_locs)
    if len-2 > num do
      new = List.delete(goal_locs,num)
      num = num + 1
      new = new ++ [num]
      stop(robot,new,:cli_robot_state)
    else
      ttr = mpid(robot)
      {:ok, %CLI.Position{x: robot.x, y: robot.y, facing: robot.facing}}
    end
  end 


  def for_loop(n,robot,er,goal_locs) when n <= 1 do
    [goal_x,goal_y] = val_ext(goal_locs)
    robot = if n == 1 do
              recA(robot)
              robot = move(robot)
              robot
            else
              robot
            end
    

    
          stop(robot,goal_locs,:cli_robot_state)
  end



  def for_loop(n,robot,er,goal_locs) do
    [goal_x,goal_y] = val_ext(goal_locs)
    recA(robot)
    robot = move(robot)
    ttr = mpid(robot)
    if ttr do
      avoid(robot,goal_locs)
    else
      for_loop(n - 1, robot,er,goal_locs)
    end
    
  end



  def mpid(robot) do
    parent = self()
    pid = spawn_link(fn -> x = send_robot_status(robot, :cli_robot_state); send(parent, {:ok, x}) end)
    Process.register(pid, :client_toyrobotA)

    # robo_pre = recA(robot)
    del(pid)

  end

  def del(pid) do
    parent = self()
    if Process.alive? pid do
      del(pid)
    else
      receive do
        {:ok,x} -> x
      end
    end
  end


  
  def avoid(robot,goal_locs,test \\ 0,flag \\ -1) do
    [goal_x,goal_y] = val_ext(goal_locs)
    flg = 1
    {robot, flag} = cond do
                      retest(robot) == 1 -> 
                        {left(robot), 1}
                      retest(robot) == -1 -> 
                        {right(robot), -1}
                      retest(robot) == 0 -> 
                        {robot,flag} = if flag == -1 do
                                  {right(robot), -1}
                                else
                                  {left(robot), 1}
                                end
                    end
    ttr = mpid(robot)
    check_x = robot.x
    check_y = robot.y
    if ttr do
      avoid(robot,goal_locs,test+1,flag)
    else
      recA(robot)
      robot = move(robot)
      cond do
        test != 0 -> 
          flg = 1
          ttr = mpid(robot)
          robot = if flag == -1 do
                    left(robot)
                  else
                    right(robot)
                  end
          ttr = mpid(robot)
          if ttr do
            avoid(robot,goal_locs,test+1,flag)
          else
             recA(robot)
             robot = move(robot)

             stop(robot,goal_locs,:cli_robot_state)
          end
          
        true -> stop(robot,goal_locs,:cli_robot_state)
      end
    end
  end


  def check(x,y) do
    x = if is_integer(x) do
          x
        else
          String.to_integer(x)
        end

    y = if is_atom(y) do
          y
        else
          String.to_atom(y)
        end

        [x,y]
  end



  def val_ext(list) do
    num = List.last(list)
    new = Enum.at(list,num)
    [a,b] = new
    x = if is_integer(a) do
          a
        else
          String.to_integer(a)
        end

    y = if is_atom(b) do
          b
        else
          String.to_atom(b)
        end
    [x,y]
  end 



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
    [x1,y1] = check(x1,y1)
    [x2,y2] = check(x2,y2)
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



  def arrange(startA,startB,goal_locs) do
    startA = startA
    startB = startB
    list = of(goal_locs)
    n = length(list)

    aa = Enum.at(fort(list,n,startA,"a"),1)

    bb = Enum.at(fort(list,n,startB,"b"),1)

    st = aa ++ bb
    main(startA,startB,st,length(aa))
  end


  def without_repetitions([], _k), do: [[]]


  def without_repetitions(_list, 0), do: [[]]


  def without_repetitions(list, k) do
      for head <- list, tail <- without_repetitions(list -- [head], k - 1), do: [head | tail]
  end



  def main(startA,startB,list,k,fii,mn,ind, rep) when ind == length(list) - 1 do

    x = Enum.at(list,ind)
    eA = for a <- x, Enum.at(a,2) == "a", do: List.delete_at(a,2)
    eB = for a <- x, Enum.at(a,2) == "b", do: List.delete_at(a,2)



    listA = of(eA)
    listB = of(eB)

    aa = fort(listA,length(listA),startA,"a")
    bb = fort(listB,length(listB),startB,"b")
    sumAB = Enum.at(aa,0) + Enum.at(bb,0)
    last = List.insert_at(mn,-1,sumAB)
    fii = List.insert_at(fii,-1,Enum.at(aa,1) ++ Enum.at(bb,1))
    Enum.at(fii,Enum.find_index(last, fn x -> x == Enum.min(last) end))

  end



  def main(startA,startB,list,k,fii \\ [], mn \\ [],ind \\ 0, rep \\ 0) do
    if rep == 0 do
      lis = without_repetitions(list,k)
      new = for x <- (for a <- lis, do: Enum.uniq_by(a, fn [l,m,_] -> {l,m} end)), length(x) == k, do: x
      unique = for g <- new, do: Enum.sort(g)
      final = Enum.uniq(unique)
      main(startA,startB,final,k,fii,mn,ind, rep+1)

    else
      x = Enum.at(list,ind)
      eA = for a <- x, Enum.at(a,2) == "a", do: List.delete_at(a,2)
      eB = for a <- x, Enum.at(a,2) == "b", do: List.delete_at(a,2)
      listA = of(eA)
      listB = of(eB)
      
      aa = fort(listA,length(listA),startA,"a")

      bb = fort(listB,length(listB),startB,"b")

      sumAB = Enum.at(aa,0) + Enum.at(bb,0)

      mn = List.insert_at(mn,-1,sumAB)
      fii = List.insert_at(fii,-1,Enum.at(aa,1) ++ Enum.at(bb,1))

      sumAB
      main(startA,startB,list,k,fii,mn,ind+1,rep)

    end
  end
  

  def face_error(robot_x, robot_y, x, y, robot_facing) do

    goal_y = y
    goal_x = x

    [goal_x,goal_y] = check(goal_x,goal_y)
    [robot_x,robot_y] = check(robot_x,robot_y)

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




  def rec(pid) do
    parent = self()
    if Process.alive? pid do
      rec(pid)
    else
      receive do
        {:ok,x} -> x
      end
    end
  end



  def recA(robot,a \\ [], n \\ 0) do
    x = cond do 
      n == 0 ->
          parent = self()
          pidA = spawn_link(fn -> x = listen_send(robot); send(parent, {:ok, x}) end)
          Process.register(pidA, :rec_A)
          rec(pidA)
      n == 1 ->
          parent = self()
          pidA = spawn_link(fn -> x = listen_from_B(); send(parent, {:ok, x}) end)
          Process.register(pidA, :rec_A)
          rec(pidA)
      n = 2 ->
          parent = self()
          pidA = spawn_link(fn -> x = Process.send_after(:rec_B, {:ok, a},10) end)

        end
  end

  def send_B(%CLI.Position{x: x, y: y, facing: facing} = robot, cli_proc_name) do
    Process.send_after(:rec_B, {:positionA, robot, move(robot)},10)
    # IO.puts("Sent by Toy Robot Client: #{x}, #{y}, #{facing}")
    listen_from_B()
  end

  def listen_send(robot) do
    receive do
      {:positionB, robot, move_robot} ->
        {:positionB, robot, move_robot}
        Process.send_after(:rec_B, {:positionA,robot, move(robot)},10)
    end
  end

  def listen_from_B() do
    receive do
      {:positionB,robot, move_robot} ->
        {:positionB,robot, move_robot}

      {:ok,x} -> x

    end
  end




  def stop(robot, goal_locs, cli_proc_name) do
    
    goal_locs = if is_integer(List.last(goal_locs)) do 
      goal_locs
    else 
      startB = recA(robot,[],1)
      goal_locs = arrange([robot.x,robot.y,robot.facing],startB,goal_locs)
      goal_b = for x <- goal_locs, Enum.at(x,-1) == "b", do: List.delete_at(x,-1)
      goal_locs = for x <- goal_locs, Enum.at(x,-1) == "a", do: List.delete_at(x,-1)
      recA(robot,goal_b,2)
      goal_locs = List.insert_at(goal_locs,-1,0)
    end

    if length(goal_locs) == 1 do
      ttr = mpid(robot)
      {:ok, %CLI.Position{x: robot.x, y: robot.y, facing: robot.facing}}
    else
      [x,y] = val_ext(goal_locs)
      goal_y = y
      goal_x = x


      error_x = goal_x - robot.x
      error_y = @vals_y[goal_y] - @vals_y[robot.y]
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_locs)
      else
        if @vals_facing[robot.facing] == 1 and error_y != 0 or @vals_facing[robot.facing] == 3 and error_y != 0 or error_x == 0 do
          cond do
            error_y == 0 and error_x == 0 -> {:ok,robot}
            error_y > 0 and @vals_facing[robot.facing] == 4 -> 
              err = -1 
              con_check(err,robot,error_y,error_x,goal_locs)
            error_y > 0 -> 
              err = @vals_facing[robot.facing] - 1 

              cond do
                err == 2 and error_x != 0 or err == -2 and error_x != 0 -> 
                  cond do
                    error_x > 0 -> 
                      err = @vals_facing[robot.facing] - 2
                      con_check(err,robot,error_x, error_y,goal_locs)        
                    error_x < 0 ->
                      err = @vals_facing[robot.facing] - 4
                      con_check(err,robot,error_x*(-1),error_y,goal_locs)
                  end
                true -> con_check(err,robot,error_y,error_x,goal_locs)
              end


            error_y < 0 ->
              err = @vals_facing[robot.facing] - 3

              cond do
                err == 2 and error_x != 0 or err == -2 and error_x != 0 -> 
                  cond do
                    error_x > 0 -> 
                      err = @vals_facing[robot.facing] - 2
                      con_check(err,robot,error_x, error_y,goal_locs)        
                    error_x < 0 ->
                      err = @vals_facing[robot.facing] - 4
                      con_check(err,robot,error_x*(-1),error_y,goal_locs)
                  end
                true -> con_check(err,robot,error_y*(-1),error_x,goal_locs)
              end

            error_y == 0 -> for_loop(error_y, robot, error_x,goal_locs)
          end
        else
          cond do
            error_x < 0 and @vals_facing[robot.facing] == 1 -> 
              err = 1 
              con_check(err,robot,error_x*(-1),error_y,goal_locs)
            error_x > 0 -> 
              err = @vals_facing[robot.facing] - 2


              cond do
                err == 2 and error_y != 0 or err == -2 and error_y != 0 -> 
                  cond do
                    error_y > 0 ->
                      err = @vals_facing[robot.facing] - 1 
                      con_check(err,robot,error_y,error_x,goal_locs)
                    error_y < 0 ->
                      err = @vals_facing[robot.facing] - 3
                      con_check(err,robot,error_y*(-1),error_x,goal_locs)
                  end
                true -> con_check(err,robot,error_x, error_y,goal_locs)
              end

                      
            error_x < 0 ->
              err = @vals_facing[robot.facing] - 4

              cond do
                err == 2 and error_y != 0 or err == -2 and error_y != 0 -> 
                  cond do
                    error_y > 0 ->
                      err = @vals_facing[robot.facing] - 1 
                      con_check(err,robot,error_y,error_x,goal_locs)
                    error_y < 0 ->
                      err = @vals_facing[robot.facing] - 3
                      con_check(err,robot,error_y*(-1),error_x,goal_locs)
                  end
                true -> con_check(err,robot,error_x*(-1),error_y,goal_locs)
              end

            error_x == 0 -> for_loop(error_x, robot, error_y,goal_locs)
          end
        end
      end
    end
  end

  @doc """
  Send Toy Robot's current status i.e. location (x, y) and facing
  to the CLI Server process after each action is taken.
  Listen to the CLI Server and wait for the message indicating the presence of obstacle.
  The message with the format: '{:obstacle_presence, < true or false >}'.
  """
  def send_robot_status(%CLI.Position{x: x, y: y, facing: facing} = _robot, cli_proc_name) do
    send(cli_proc_name, {:toyrobotA_status, x, y, facing})
    # IO.puts("Sent by Toy Robot Client: #{x}, #{y}, #{facing}")
    listen_from_server()
  end

  @doc """
  Listen to the CLI Server and wait for the message indicating the presence of obstacle.
  The message with the format: '{:obstacle_presence, < true or false >}'.
  """
  def listen_from_server() do
    receive do
      {:obstacle_presence, is_obs_ahead} ->
        is_obs_ahead
    end
  end

  @doc """
  Provides the report of the robot's current position

  Examples:

      iex> {:ok, robot} = CLI.ToyRobotA.place(2, :b, :west)
      iex> CLI.ToyRobotA.report(robot)
      {2, :b, :west}
  """
  def report(%CLI.Position{x: x, y: y, facing: facing} = _robot) do
    {x, y, facing}
  end

  @directions_to_the_right %{north: :east, east: :south, south: :west, west: :north}
  @doc """
  Rotates the robot to the right
  """
  def right(%CLI.Position{facing: facing} = robot) do
    %CLI.Position{robot | facing: @directions_to_the_right[facing]}
  end

  @directions_to_the_left Enum.map(@directions_to_the_right, fn {from, to} -> {to, from} end)
  @doc """
  Rotates the robot to the left
  """
  def left(%CLI.Position{facing: facing} = robot) do
    %CLI.Position{robot | facing: @directions_to_the_left[facing]}
  end

  @doc """
  Moves the robot to the north, but prevents it to fall
  """
  def move(%CLI.Position{x: _, y: y, facing: :north} = robot) when y < @table_top_y do
    %CLI.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) + 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the east, but prevents it to fall
  """
  def move(%CLI.Position{x: x, y: _, facing: :east} = robot) when x < @table_top_x do
    %CLI.Position{robot | x: x + 1}
  end

  @doc """
  Moves the robot to the south, but prevents it to fall
  """
  def move(%CLI.Position{x: _, y: y, facing: :south} = robot) when y > :a do
    %CLI.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) - 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the west, but prevents it to fall
  """
  def move(%CLI.Position{x: x, y: _, facing: :west} = robot) when x > 1 do
    %CLI.Position{robot | x: x - 1}
  end

  @doc """
  Does not change the position of the robot.
  This function used as fallback if the robot cannot move outside the table
  """
  def move(robot), do: robot

  def failure do
    raise "Connection has been lost"
  end
end
