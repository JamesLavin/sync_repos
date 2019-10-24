defmodule Log do
  def output(token) do
    output_dir = Path.expand(token.sync_dir) <> "/logs"
    make_log_dir(output_dir)
    save_output(token, output_dir)
    token
  end

  defp save_output(token, output_dir) do
    filename = "sync_repos_" <> token.timestamp
    write_path = Path.join(output_dir, filename)
    File.write(write_path, inspect(token, pretty: true))
  end

  defp make_log_dir(output_dir) do
    unless File.exists?(output_dir) do
      File.mkdir(output_dir)
    end
  end
end
