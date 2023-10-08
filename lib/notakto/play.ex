defmodule Notakto.Play do
  defstruct row: nil, col: nil, player: nil

  @type t :: %__MODULE__{
          row: integer(),
          col: integer(),
          player: atom()
        }

  @spec new(integer(), integer(), atom()) :: t()
  def new(row, col, player) do
    %Notakto.Play{row: row, col: col, player: player}
  end
end
