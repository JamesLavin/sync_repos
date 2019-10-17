defmodule Log do
  def output(args) do
    output_dir = Path.expand(args[:sync_dir]) <> "/logs"
    make_log_dir(output_dir)
    save_output(args, output_dir)
  end

  defp save_output(args, output_dir) do
    filename = "sync_repos_" <> args[:timestamp]
    write_path = Path.join(output_dir, filename)
    File.write(write_path, inspect(args, pretty: true))
  end

  defp make_log_dir(output_dir) do
    unless File.exists?(output_dir) do
      File.mkdir(output_dir)
    end
  end
end
