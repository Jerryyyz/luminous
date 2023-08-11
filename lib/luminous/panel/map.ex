defmodule Luminous.Panel.Map do
  alias Luminous.Query
  @behaviour Luminous.Panel

  @type panel_type :: :map
  @type t :: %__MODULE__{
          id: atom(),
          title: binary(),
          type: panel_type(),
          description: binary(),
          queries: [Query.t()],
          hook: binary(),
          map: binary()
        }

  @enforce_keys [:id, :title, :queries, :hook]
  defstruct [
    :id,
    :title,
    :type,
    :description,
    :queries,
    :unit,
    :hook,
    :map
  ]

  @impl true
  @spec define(atom(), binary(), panel_type(), [Query.t()], Keyword.t()) :: t()
  def define(id, title, type, queries, opts \\ []) do
    if length(queries) > 1, do: raise("Map type only supports one query")

    %__MODULE__{
      id: id,
      title: title,
      type: type,
      queries: queries,
      description: Keyword.get(opts, :description),
      hook: Keyword.get(opts, :hook, "MapHook"),
      map: Keyword.get(opts, :map)
    }
  end

  @impl true
  def transform(%Query.Result{rows: rows, attrs: _}), do: rows
end
