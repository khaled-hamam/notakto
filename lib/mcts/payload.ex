defmodule MCTS.Payload do
  defstruct(state: nil, wins: 0, visits: 0, fully_expanded: false)

  @type t :: %__MODULE__{
          state: any(),
          wins: non_neg_integer(),
          visits: non_neg_integer(),
          fully_expanded: boolean()
        }
end
