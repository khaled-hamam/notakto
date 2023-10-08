defmodule MCTS.Node do
  alias MCTS.Payload

  @enforce_keys [:payload]
  defstruct(payload: %Payload{}, children: [])

  @type t :: %__MODULE__{payload: Payload.t(), children: [__MODULE__.t()]}

  @spec leaf?(__MODULE__.t()) :: boolean()
  def leaf?(node = %__MODULE__{}), do: Enum.empty?(node.children)

  @spec fully_expanded?(%__MODULE__{}) :: boolean()
  def fully_expanded?(%__MODULE__{payload: _payload, children: children}) do
    Enum.all?(children, fn child -> child.payload.visits > 0 end)
  end
end
