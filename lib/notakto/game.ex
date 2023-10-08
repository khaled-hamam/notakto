defmodule Notakto.Game do
  alias Notakto.{Play, State}

  @type player :: :none | :x | :y

  @spec start(integer()) :: State.t()
  def start(n) do
    board =
      for row <- 0..(n - 1) do
        for col <- 0..(n - 1) do
          %{row: row, col: col, player: :none}
        end
      end
      |> Enum.flat_map(& &1)
      |> Map.new(fn cell -> {[cell.row, cell.col], cell.player} end)

    State.new(board)
  end

  @spec legalPlays(State.t()) :: list(Play.t())
  def legalPlays(state) do
    nextPlayer = nextPlayer(state)

    state.board
    |> Map.to_list()
    |> Enum.filter(fn {_, player} -> player == :none end)
    |> Enum.map(fn {[row, col], _} -> Play.new(row, col, nextPlayer) end)
  end

  @spec nextState(State.t(), [integer()]) :: State.t()
  def nextState(state, [row, col]) do
    board =
      state.board
      |> Map.put([row, col], nextPlayer(state))

    %{state | board: board, plays: state.plays ++ [[row, col]]}
  end

  @spec winner(State.t()) :: player()
  def winner(state) do
    hasWinner =
      Map.keys(state.board)
      |> Enum.flat_map(fn [row, col] ->
        [
          [[row, col - 1], [row, col], [row, col + 1]],
          [[row - 1, col], [row, col], [row + 1, col]],
          [[row - 1, col - 1], [row, col], [row + 1, col + 1]],
          [[row - 1, col + 1], [row, col], [row + 1, col - 1]]
        ]
      end)
      |> Enum.map(fn triplet -> Enum.map(triplet, &Map.get(state.board, &1)) end)
      |> Enum.filter(fn triplet -> Enum.all?(triplet, &(&1 == :x || &1 == :y)) end)
      |> Enum.any?()

    case hasWinner do
      true -> nextPlayer(state)
      false -> :none
    end
  end

  @spec nextPlayer(State.t()) :: player()
  def nextPlayer(state) do
    case state.board
         |> Map.values()
         |> Enum.filter(&(&1 != :none))
         |> length()
         |> rem(2) do
      0 -> :x
      1 -> :y
    end
  end
end
