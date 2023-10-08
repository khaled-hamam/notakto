defmodule Notakto.State do
  defstruct board: nil, plays: []

  @type t :: %__MODULE__{
          board: map(),
          plays: list(Notakto.Play.t())
        }

  @spec new(map()) :: t()
  def new(board) do
    %Notakto.State{board: board, plays: []}
  end

  @spec hash(t()) :: String.t()
  def hash(state) do
    state.plays
    |> Enum.map(fn [col, row] -> "[#{row},#{col}]" end)
    |> Enum.join(",")
  end
end
