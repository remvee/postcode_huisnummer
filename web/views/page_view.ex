defmodule PostcodeHuisnummer.PageView do
  use PostcodeHuisnummer.Web, :view

  def time_difference(from, to) do
    seconds = (
      :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(to)) -
      :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(from))
    )
    minutes = div(seconds, 60)
    hours = div(minutes, 60)
    "#{hours} uur en #{rem(minutes, 60)} minuten en #{rem(seconds, 60)} seconden"
  end
end
