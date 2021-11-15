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
    {:ok, %ToyRobot.Position{x: x, y: y, facing: facing}}
  end

  def stop(_robot, goal_x, goal_y, _cli_proc_name) when goal_x < 1 or goal_y < :a or goal_x > @table_top_x or goal_y > @table_top_y do
    {:failure, "Invalid STOP position"}
  end

  @doc """
  Provide STOP position to the robot as given location of (x, y) and plan the path from START to STOP.
  Passing the CLI Server process name that will be used to send robot's current status after each action is taken.
  Spawn a process and register it with name ':client_toyrobot' which is used by CLI Server to send an
  indication for the presence of obstacle ahead of robot's current position and facing.
  """
  @vals_facing %{north: 1, east: 2, south: 3, west: 4}
  @vals_y %{a: 1, b: 2, c: 3, d: 4, e: 5}

  def retest(robot) do
    x = robot.x
    y = @vals_y[robot.y]
    f = @vals_facing[robot.facing]
    cond do
      y == 1 -> f - 1
      x == 1 -> f - 2
      y == 5 -> f - 3
      x == 5 and f == 1 -> 1
      x == 5 and f == 3 -> -1
      true -> -1
    end
  end


def for_check(n,robot,t,erro,er,goal_x,goal_y) when n == 1 do
    if t == 'r' do
      robot = right(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_x,goal_y)
      else
        for_loop(erro, robot, er,goal_x,goal_y)
      end
      
    else
      robot = left(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_x,goal_y)
      else
        for_loop(erro, robot, er,goal_x,goal_y)
      end
    end
  end



  def for_check(n,robot,t,erro, er,goal_x,goal_y) do
    if t == 'r' do
      robot = right(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_x,goal_y)
      else
        for_check(n - 1, robot,t,erro,er,goal_x,goal_y)
      end
    else
      robot = left(robot)
      ttr = mpid(robot)
      if ttr do
        avoid(robot,goal_x,goal_y)
      else
        for_check(n - 1, robot,t,erro,er,goal_x,goal_y)
      end
    end
  end


  def con_check(n,robot,erro,er,goal_x,goal_y) do 
    cond do
      n >= 1 -> for_check(n,robot,'l',erro, er,goal_x,goal_y)
      n <= -1 -> for_check(n*(-1),robot,'r',erro, er,goal_x,goal_y)
      n==0 -> for_loop(erro, robot, er,goal_x,goal_y)
    end
  end



  def for_loop(n,robot,er,goal_x,goal_y) when n == 1 and er == 0 do
    robot = move(robot)
    ttr = mpid(robot)
    {:ok, %ToyRobot.Position{x: robot.x, y: robot.y, facing: robot.facing}}
  end 


  def for_loop(n,robot,er,goal_x,goal_y) when n <= 1 do
    robot = if n == 1 do
              robot = move(robot)
              robot
            else
              robot
            end
    stop(robot,goal_x,goal_y,:cli_robot_state)
  end



  def for_loop(n,robot,er,goal_x,goal_y) do
    robot = move(robot)
    ttr = mpid(robot)
    if ttr do
      avoid(robot,goal_x,goal_y)
    else
      for_loop(n - 1, robot,er,goal_x,goal_y)
    end
    
  end



  def mpid(robot) do
    parent = self()
    pid = spawn_link(fn -> x = send_robot_status(robot, :cli_robot_state); send(parent, {:ok, x}) end)
    Process.register(pid, :client_toyrobot)
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


  def avoid(robot,goal_x,goal_y,flag \\ -1) do
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
      avoid(robot,goal_x,goal_y,flag)
    else
      robot = move(robot)
      cond do
        @vals_y[goal_y] == @vals_y[check_y] or goal_x == check_x or flg == 1 -> 
          flg = 1
          ttr = mpid(robot)
          robot = if flag == -1 do
                    left(robot)
                  else
                    right(robot)
                  end
          ttr = mpid(robot)
          if ttr do
            stop(robot,goal_x,goal_y,:cli_robot_state)
          else
             robot = move(robot)
             ttr = mpid(robot)
             robot = if flag == -1 do
                    left(robot)
                  else
                    right(robot)
                  end
             stop(robot,goal_x,goal_y,:cli_robot_state)
          end
          
        true -> stop(robot,goal_x,goal_y,:cli_robot_state)
      end
    end
  end

  def stop(robot, goal_x, goal_y, cli_proc_name) do
    error_x = goal_x - robot.x
    error_y = @vals_y[goal_y] - @vals_y[robot.y]
    ttr = mpid(robot)
    if ttr do
      avoid(robot,goal_x,goal_y)
    else
      if @vals_facing[robot.facing] == 1 and error_y != 0 or @vals_facing[robot.facing] == 3 and error_y != 0 or error_x == 0 do
        cond do
          error_y == 0 and error_x == 0 -> {:ok,robot}
          error_y > 0 and @vals_facing[robot.facing] == 4 -> 
            err = -1 
            con_check(err,robot,error_y,error_x,goal_x,goal_y)
          error_y > 0 -> 
            err = @vals_facing[robot.facing] - 1 
            con_check(err,robot,error_y,error_x,goal_x,goal_y)
          error_y < 0 ->
            err = @vals_facing[robot.facing] - 3
            con_check(err,robot,error_y*(-1),error_x,goal_x,goal_y)
          error_y == 0 -> for_loop(error_y, robot, error_x,goal_x,goal_y)
        end
      else
        cond do
          error_x < 0 and @vals_facing[robot.facing] == 1 -> 
            err = 1 
            con_check(err,robot,error_x*(-1),error_y,goal_x,goal_y)
          error_x > 0 -> 
            err = @vals_facing[robot.facing] - 2
            con_check(err,robot,error_x, error_y,goal_x,goal_y)        
          error_x < 0 ->
            err = @vals_facing[robot.facing] - 4
            con_check(err,robot,error_x*(-1),error_y,goal_x,goal_y)
          error_x == 0 -> for_loop(error_x, robot, error_y,goal_x,goal_y)
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
  def send_robot_status(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot, cli_proc_name) do
    send(cli_proc_name, {:toyrobot_status, x, y, facing})
    # IO.puts("Sent by Toy Robot Client: #{x}, #{y}, #{facing}")
    listen_from_server()
  end

  @doc """
  Listen to the CLI Server and wait for the message indicating the presence of obstacle.
  The message with the format: '{:obstacle_presence, < true or false >}'.
  """
  def listen_from_server() do
    receive do
        {:obstacle_presence, is_obs_ahead} -> is_obs_ahead
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
