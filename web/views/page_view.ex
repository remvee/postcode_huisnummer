defmodule PostcodeHuisnummer.PageView do
  use PostcodeHuisnummer.Web, :view

  def time_difference(from, to) do
    seconds = (
      :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(to)) -
      :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(from))
    )
    minutes = div(seconds, 60)
    hours = div(minutes, 60)
    [
      hours > 0 && "#{hours} uur",
      rem(minutes, 60) > 0 && "#{rem(minutes, 60)} minuten",
      rem(seconds, 60) > 0 && "#{rem(seconds, 60)} seconden"
    ]
    |> Enum.filter(&(&1))
    |> Enum.join(" ")
  end

  def bag_version(sync) do
    [
      sync.last_modified,
      sync.count && "(" <> to_string(sync.count) <> " adressen)",
    ]
    |> Enum.filter(&(&1))
    |> Enum.join(" ")
  end
end
