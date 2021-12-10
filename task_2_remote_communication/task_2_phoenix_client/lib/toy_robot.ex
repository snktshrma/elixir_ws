defmodule ToyRobot do
  # max x-coordinate of table top
  @table_top_x 5
  # max y-coordinate of table top
  @table_top_y :e
  # mapping of y-coordinates
  @robot_map_y_atom_to_num %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}

  @doc """
  Places the robot to the default position of (1, A, North)

  Examples:

      iex> ToyRobot.place
      {:ok, %ToyRobot.Position{facing: :north, x: 1, y: :a}}
  """
  def place do
    {:ok, %ToyRobot.Position{}}
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

      iex> ToyRobot.place(1, :b, :south)
      {:ok, %ToyRobot.Position{facing: :south, x: 1, y: :b}}

      iex> ToyRobot.place(-1, :f, :north)
      {:failure, "Invalid position"}

      iex> ToyRobot.place(3, :c, :north_east)
      {:failure, "Invalid facing direction"}
  """
  def place(x, y, facing) do
    {:ok, %ToyRobot.Position{x: x, y: y, facing: facing}}
  end

  @doc """
  Provide START position to the robot as given location of (x, y, facing) and place it.
  """
  def start(x, y, facing) do
    ###########################
    ## complete this funcion ##
    ###########################
    place(x, y, facing)
  end

  def stop(_robot, goal_x, goal_y, _channel) when goal_x < 1 or goal_y < :a or goal_x > @table_top_x or goal_y > @table_top_y do
    {:failure, "Invalid STOP position"}
  end

  @doc """
  Provide STOP position to the robot as given location of (x, y) and plan the path from START to STOP.
  Passing the channel PID on the Phoenix Server that will be used to send robot's current status after each action is taken.
  Make a call to ToyRobot.PhoenixSocketClient.send_robot_status/2
  to get the indication of obstacle presence ahead of the robot.
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


  def for_check(n,robot,t,erro,er,goal_x,goal_y, channel) when n == 1 do
    if t == 'r' do
      robot = right(robot)
      ttr = mpid(robot, channel)
      if ttr do
        avoid(robot,goal_x,goal_y, channel)
      else
        for_loop(erro, robot, er,goal_x,goal_y, channel)
      end
      
    else
      robot = left(robot)
      ttr = mpid(robot, channel)
      if ttr do
        avoid(robot,goal_x,goal_y, channel)
      else
        for_loop(erro, robot, er,goal_x,goal_y, channel)
      end
    end
  end



  def for_check(n,robot,t,erro, er,goal_x,goal_y, channel) do
    if t == 'r' do
      robot = right(robot)
      ttr = mpid(robot, channel)
      if ttr do
        avoid(robot,goal_x,goal_y, channel)
      else
        for_check(n - 1, robot,t,erro,er,goal_x,goal_y, channel)
      end
    else
      robot = left(robot)
      ttr = mpid(robot, channel)
      if ttr do
        avoid(robot,goal_x,goal_y, channel)
      else
        for_check(n - 1, robot,t,erro,er,goal_x,goal_y, channel)
      end
    end
  end


  def con_check(n,robot,erro,er,goal_x,goal_y, channel) do 
    cond do
      n >= 1 -> for_check(n,robot,'l',erro, er,goal_x,goal_y, channel)
      n <= -1 -> for_check(n*(-1),robot,'r',erro, er,goal_x,goal_y, channel)
      n==0 -> for_loop(erro, robot, er,goal_x,goal_y, channel)
    end
  end



  def for_loop(n,robot,er,goal_x,goal_y, channel) when n == 1 and er == 0 do
    robot = move(robot)
    ttr = mpid(robot, channel)
    {:ok, %ToyRobot.Position{x: robot.x, y: robot.y, facing: robot.facing}}
  end 


  def for_loop(n,robot,er,goal_x,goal_y, channel) when n <= 1 do
    robot = if n == 1 do
              robot = move(robot)
              robot
            else
              robot
            end
    stop(robot,goal_x,goal_y,channel)
  end



  def for_loop(n,robot,er,goal_x,goal_y, channel) do
    robot = move(robot)
    ttr = mpid(robot, channel)
    if ttr do
      avoid(robot,goal_x,goal_y, channel)
    else
      for_loop(n - 1, robot,er,goal_x,goal_y, channel)
    end
    
  end



  def mpid(robot, channel) do
    ToyRobot.PhoenixSocketClient.send_robot_status(channel, robot)
  end


  def avoid(robot,goal_x,goal_y,flag \\ -1,channel) do
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
    ttr = mpid(robot, channel)
    check_x = robot.x
    check_y = robot.y
    if ttr do
      avoid(robot,goal_x,goal_y,flag,channel)
    else
      robot = move(robot)
      cond do
        @vals_y[goal_y] == @vals_y[check_y] or goal_x == check_x or flg == 1 -> 
          flg = 1
          ttr = mpid(robot, channel)
          robot = if flag == -1 do
                    left(robot)
                  else
                    right(robot)
                  end
          ttr = mpid(robot, channel)
          if ttr do
            stop(robot,goal_x,goal_y,channel)
          else
             robot = move(robot)
             ttr = mpid(robot, channel)
             robot = if flag == -1 do
                    left(robot)
                  else
                    right(robot)
                  end
             stop(robot,goal_x,goal_y,channel)
          end
          
        true -> stop(robot,goal_x,goal_y,channel)
      end
    end
  end

  def stop(robot, goal_x, goal_y,channel) do
    error_x = goal_x - robot.x
    error_y = @vals_y[goal_y] - @vals_y[robot.y]
    ttr = mpid(robot, channel)
    if ttr do
      avoid(robot,goal_x,goal_y, channel)
    else
      if @vals_facing[robot.facing] == 1 and error_y != 0 or @vals_facing[robot.facing] == 3 and error_y != 0 or error_x == 0 do
        cond do
          error_y == 0 and error_x == 0 -> {:ok,robot}
          error_y > 0 and @vals_facing[robot.facing] == 4 -> 
            err = -1 
            con_check(err,robot,error_y,error_x,goal_x,goal_y, channel)
          error_y > 0 -> 
            err = @vals_facing[robot.facing] - 1 
            con_check(err,robot,error_y,error_x,goal_x,goal_y, channel)
          error_y < 0 ->
            err = @vals_facing[robot.facing] - 3
            con_check(err,robot,error_y*(-1),error_x,goal_x,goal_y, channel)
          error_y == 0 -> for_loop(error_y, robot, error_x,goal_x,goal_y, channel)
        end
      else
        cond do
          error_x < 0 and @vals_facing[robot.facing] == 1 -> 
            err = 1 
            con_check(err,robot,error_x*(-1),error_y,goal_x,goal_y, channel)
          error_x > 0 -> 
            err = @vals_facing[robot.facing] - 2
            con_check(err,robot,error_x, error_y,goal_x,goal_y, channel)        
          error_x < 0 ->
            err = @vals_facing[robot.facing] - 4
            con_check(err,robot,error_x*(-1),error_y,goal_x,goal_y, channel)
          error_x == 0 -> for_loop(error_x, robot, error_y,goal_x,goal_y, channel)
        end
      end
    end
  end

  @doc """
  Provides the report of the robot's current position

  Examples:

      iex> {:ok, robot} = ToyRobot.place(2, :b, :west)
      iex> ToyRobot.report(robot)
      {2, :b, :west}
  """
  def report(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot) do
    {x, y, facing}
  end

  @directions_to_the_right %{north: :east, east: :south, south: :west, west: :north}
  @doc """
  Rotates the robot to the right
  """
  def right(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_right[facing]}
  end

  @directions_to_the_left Enum.map(@directions_to_the_right, fn {from, to} -> {to, from} end)
  @doc """
  Rotates the robot to the left
  """
  def left(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_left[facing]}
  end

  @doc """
  Moves the robot to the north, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: _, y: y, facing: :north} = robot) when y < @table_top_y do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) + 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the east, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: x, y: _, facing: :east} = robot) when x < @table_top_x do
    %ToyRobot.Position{robot | x: x + 1}
  end

  @doc """
  Moves the robot to the south, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: _, y: y, facing: :south} = robot) when y > :a do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) - 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the west, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: x, y: _, facing: :west} = robot) when x > 1 do
    %ToyRobot.Position{robot | x: x - 1}
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
