defmodule SyncRepos.Display do
  def simplified(args) do
    simplified =
      args[:processed]
      |> Enum.map(&keep_desired_fields/1)

    put_in(args, [:processed], simplified)
  end

  defp keep_desired_fields(repo) do
    desired_fields = [:dir, :halt_reason, :changes_pulled, :changes_pushed]
    Map.take(repo, desired_fields)
  end
end
