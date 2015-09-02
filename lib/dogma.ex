defmodule Dogma do
  @moduledoc """
  Welcome to Dogma.

  This module is our entry point, and does nothing but deligate to various
  other modules through the divine `run/2` function.
  """

  alias Dogma.Formatter
  alias Dogma.Rules
  alias Dogma.ScriptSources

  def run({dir, formatter}) do
    dir
    |> ScriptSources.find(exclude_patterns)
    |> ScriptSources.to_scripts
    |> Formatter.start(formatter)
    |> Rules.test(formatter)
    |> Formatter.finish(formatter)
  end

  defp exclude_patterns do
    Application.get_env :dogma, :exclude, []
  end
end
