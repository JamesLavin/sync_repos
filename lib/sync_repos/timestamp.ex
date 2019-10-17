defmodule SyncRepos.Timestamp do
  def now do
    {{yyyy, mon, dd}, {hh, min, ss}} = :os.timestamp() |> :calendar.now_to_datetime()
    yyyy = yyyy |> to_string()
    mon = mon |> to_string() |> String.pad_leading(2, "0")
    dd = dd |> to_string() |> String.pad_leading(2, "0")
    hh = hh |> to_string() |> String.pad_leading(2, "0")
    min = min |> to_string() |> String.pad_leading(2, "0")
    ss = ss |> to_string() |> String.pad_leading(2, "0")

    ~s/#{yyyy}#{mon}#{dd}#{hh}#{min}#{ss}/
  end
end
