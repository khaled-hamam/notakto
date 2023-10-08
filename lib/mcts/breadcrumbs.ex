defmodule MCTS.Breadcrumb do
  alias MCTS.{Node, Payload}

  @enforce_keys [:payload, :left_nodes, :right_nodes]
  defstruct(
    payload: nil,
    left_nodes: [],
    right_nodes: []
  )

  @type t :: %__MODULE__{payload: Payload.t(), left_nodes: [Node.t()], right_nodes: [Node.t()]}
end
