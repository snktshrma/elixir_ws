defmodule ToyRobot do
  # max x-coordinate of table top
  @table_top_x 5
  # max y-coordinate of table top
  @table_top_y :e
  # mapping of y-coordinates
  @robot_map_y_atom_to_num %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}

  
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

  
  def place(x, y, facing) do
    {:ok, %ToyRobot.Position{x: x, y: y, facing: facing}}
  end

  
  def start(x, y, facing) do
    {:ok, %ToyRobot.Position{x: x, y: y, facing: facing}}
  end

  def stop(_robot, goal_x, goal_y, _cli_proc_name) when goal_x < 1 or goal_y < :a or goal_x > @table_top_x or goal_y > @table_top_y do
    {:failure, "Invalid STOP position"}
  end






  def for_check(n,robot,t,erro,er) when n == 1 do
    if t == 'r' do
      robot = right(robot)
      send_robot_status(robot, :cli_robot_state)
      unless erro == 0 and er == 0 do
        for_loop(erro, robot, er)
      end
    else
      robot = left(robot)
      send_robot_status(robot, :cli_robot_state)
      unless erro == 0 and er == 0 do
        for_loop(erro, robot,er)
      end
    end
  end

  def for_check(n,robot,t,erro, er) do
    if t == 'r' do
      robot = right(robot)
      send_robot_status(robot, :cli_robot_state)
      for_check(n - 1, robot,t,erro,er)
    else
      robot = left(robot)
      send_robot_status(robot, :cli_robot_state)
      for_check(n - 1, robot,t, erro,er)
    end
  end



  def con_check(n,robot,erro,er) do 
    cond do
      n >= 1 -> for_check(n,robot,'l',erro, er)
      n <= -1 -> for_check(n*(-1),robot,'r',erro, er)
      n==0 -> for_loop(erro, robot, er)
    end
  end

  @vals_facing %{north: 1, east: 2, south: 3, west: 4}
  @vals_y %{a: 1, b: 2, c: 3, d: 4, e: 5}

  def for_loop(n,robot,er) when n == 1 and er == 1 do
    robot = move(robot)
    send_robot_status(robot, :cli_robot_state)
    {:ok, %ToyRobot.Position{x: robot.x, y: robot.y, facing: robot.facing}}
  end 

  def for_loop(n,robot,er) when n == 1 and 0 <= er and er <= 1 do
    robot = move(robot)
    send_robot_status(robot, :cli_robot_state)
    {:ok, %ToyRobot.Position{x: robot.x, y: robot.y, facing: robot.facing}}
  end 


  def for_loop(n,robot,er) when n == 0 do
    if er >= 0 do
      err = @vals_facing[robot.facing] - 2
      con_check(err,robot,er, n)
    else
      err = @vals_facing[robot.facing] - 4
      con_check(err,robot,er*(-1),n)
    end
  end




  def for_loop(n,robot,er) when n <= 1 do
    robot = move(robot)
    send_robot_status(robot, :cli_robot_state)
    if er >= 0 do
      err = @vals_facing[robot.facing] - 2
      con_check(err,robot,er, n)
    else
      err = @vals_facing[robot.facing] - 4
      con_check(err,robot,er*(-1),n)
    end
  end

  def for_loop(n,robot,er) do

    robot = move(robot)
    send_robot_status(robot, :cli_robot_state)
    for_loop(n - 1, robot,er)
  end





  def stop(robot, goal_x, goal_y, cli_proc_name) do
    error_x = goal_x - robot.x
    error_y = @vals_y[goal_y] - @vals_y[robot.y]
    send_robot_status(robot, :cli_robot_state)
    cond do
      error_y == 0 and error_x == 0 -> {:ok,robot}
      error_y > 0 -> 
        err = @vals_facing[robot.facing] - 1 
        con_check(err,robot,error_y,error_x)
      error_y < 0 ->
        err = @vals_facing[robot.facing] - 3
        con_check(err,robot,error_y*(-1),error_x)
      error_y == 0 -> for_loop(error_y, robot, error_x)
    end

  end













  def send_robot_status(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot, cli_proc_name) do
    send(cli_proc_name, {:toyrobot_status, x, y, facing})
    # IO.puts("Sent by Toy Robot Client: #{x}, #{y}, #{facing}")
  end


  def report(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot) do
    {x, y, facing}
  end

  @directions_to_the_right %{north: :east, east: :south, south: :west, west: :north}
  
  def right(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_right[facing]}
  end

  @directions_to_the_left Enum.map(@directions_to_the_right, fn {from, to} -> {to, from} end)
  
  def left(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_left[facing]}
  end

 
  def move(%ToyRobot.Position{x: _, y: y, facing: :north} = robot) when y < @table_top_y do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) + 1 end) |> elem(0)}
  end

  
  def move(%ToyRobot.Position{x: x, y: _, facing: :east} = robot) when x < @table_top_x do
    %ToyRobot.Position{robot | x: x + 1}
  end

  
  def move(%ToyRobot.Position{x: _, y: y, facing: :south} = robot) when y > :a do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) - 1 end) |> elem(0)}
  end


  def move(%ToyRobot.Position{x: x, y: _, facing: :west} = robot) when x > 1 do
    %ToyRobot.Position{robot | x: x - 1}
  end

  def move(robot), do: robot

  def failure do
    raise "Connection has been lost"
  end
end