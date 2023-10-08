defmodule MCTS do
  alias MCTS.{Node, Payload, Zipper}
  alias Notakto.{Game, Play, State}

  @typep zipper_with_game_result :: {%Zipper{}, Game.player()}

  @spec search(%State{}, pos_integer()) :: %Play{}
  def search(state, iterations) do
    unless is_integer(iterations) do
      raise ArgumentError, "resource amount must be an integer, got: #{inspect(iterations)}"
    end

    root_node = %Node{payload: %Payload{state: state}}
    currentPlayer = Game.nextPlayer(state)
    zipper = %Zipper{focus: root_node, metadata: %{currentPlayer: currentPlayer}}

    node = search(zipper, 0, iterations, state)

    List.last(node.payload.state.plays)
  end

  @spec search(%Zipper{}, non_neg_integer(), pos_integer(), %State{}) :: %Node{}
  defp search(zipper, simulations_completed, simulations_to_run, state) do
    if simulations_completed < simulations_to_run do
      zipper
      |> select()
      |> simulate()
      |> backpropagate()
      |> search(simulations_completed + 1, simulations_to_run, state)
    else
      best_child(zipper)
    end
  end

  @spec select(%Zipper{}) :: zipper_with_game_result()
  defp select(zipper) do
    hasPlays = Game.legalPlays(zipper.focus.payload.state) != []

    if zipper.focus.payload.fully_expanded && hasPlays do
      {new_zipper, winner} = select_best_uct(zipper)

      if winner == :none do
        select(new_zipper)
      else
        {new_zipper, winner}
      end
    else
      {zipper, :none}
    end
  end

  @spec simulate(zipper_with_game_result()) :: zipper_with_game_result()
  defp simulate({zipper, :none}) do
    zipper_ =
      if zipper.focus.payload.visits == 0 do
        expand_focused_node(zipper)
      else
        zipper
      end

    zipper_
    |> select_random_unvisited()
    |> simulate()
  end

  defp simulate({zipper, winner}) do
    {zipper, winner}
  end

  @spec backpropagate(zipper_with_game_result()) :: %Zipper{}
  defp backpropagate({zipper, winner}) do
    new_zipper = update_payload(zipper, winner)

    if Zipper.root?(new_zipper) do
      new_zipper
    else
      backpropagate({Zipper.up(new_zipper), winner})
    end
  end

  @spec update_payload(%Zipper{}, Game.player()) :: %Zipper{}
  defp update_payload(zipper, winner) do
    player = Game.nextPlayer(zipper.focus.payload.state)

    %{
      zipper
      | focus: %{
          zipper.focus
          | payload: %{
              zipper.focus.payload
              | visits: zipper.focus.payload.visits + 1,
                wins: zipper.focus.payload.wins + win(winner, player),
                fully_expanded: Node.fully_expanded?(zipper.focus)
            }
        }
    }
  end

  @spec win(Game.player(), Game.player()) :: integer()
  defp win(winner, player) do
    if winner == player, do: 0, else: 1
  end

  @spec best_child(%Zipper{}) :: %Node{}
  defp best_child(zipper) do
    Enum.max_by(zipper.focus.children, fn node -> node.payload.visits end)
  end

  @spec select_best_uct(%Zipper{}) :: zipper_with_game_result()
  defp select_best_uct(zipper) do
    best_uct_node_with_index =
      zipper.focus.children
      |> Enum.with_index()
      |> Enum.max_by(fn {node, _index} -> uct(zipper.focus, node) end)

    select_node(zipper, best_uct_node_with_index)
  end

  @spec select_node(%Zipper{}, {%Node{}, non_neg_integer()}) :: zipper_with_game_result()
  defp select_node(zipper = %Zipper{}, node_with_index) do
    {%Node{payload: %Payload{state: state}}, index} = node_with_index

    nextState = Game.nextState(state, List.last(state.plays))
    new_zipper = Zipper.down(zipper, index)

    {new_zipper, Game.winner(nextState)}
  end

  # UCT (Upper Confidence bounds applied to Trees) function.
  #
  # References:
  # - https://en.wikipedia.org/wiki/Monte_Carlo_tree_search#Exploration_and_exploitation
  # - https://www.chessprogramming.org/UCT#Selection
  @spec uct(%Node{}, %Node{}) :: float()
  defp uct(parent_node = %Node{}, child_node = %Node{}) do
    child_node_wins = child_node.payload.wins
    child_node_visits = child_node.payload.visits

    win_ratio = child_node_wins / child_node_visits

    exploration_constant = :math.sqrt(2)
    parent_node_visits = parent_node.payload.visits

    win_ratio + exploration_constant +
      :math.sqrt(:math.log(parent_node_visits) / child_node_visits)
  end

  @spec select_random_unvisited(%Zipper{}) :: zipper_with_game_result()
  defp select_random_unvisited(zipper) do
    random_unvisited_child_node_with_index =
      zipper.focus.children
      |> Enum.with_index()
      |> Enum.filter(fn {node, _index} -> node.payload.visits == 0 end)
      |> Enum.random()

    select_node(zipper, random_unvisited_child_node_with_index)
  end

  @spec expand_focused_node(%Zipper{}) :: %Zipper{}
  defp expand_focused_node(zipper) do
    plays = Game.legalPlays(zipper.focus.payload.state)

    %{
      zipper
      | focus: %{
          zipper.focus
          | children:
              Enum.map(plays, fn play ->
                %Node{
                  payload: %Payload{
                    state: Game.nextState(zipper.focus.payload.state, [play.row, play.col])
                  }
                }
              end),
            payload: %{ zipper.focus.payload | fully_expanded: Node.fully_expanded?(zipper.focus) }
        }
    }
  end
end
