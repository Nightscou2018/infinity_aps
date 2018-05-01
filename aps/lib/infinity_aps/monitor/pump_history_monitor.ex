defmodule InfinityAPS.Monitor.PumpHistoryMonitor do
  @moduledoc false
  require Logger

  alias Pummpcomm.Monitor.HistoryMonitor

  def loop(local_timezone) do
    history_response = HistoryMonitor.get_pump_history(1440, local_timezone)

    with {:ok, history} <- history_response do
      write_history(history, local_timezone)
    end
  end

  def write_history(history, local_timezone) do
    history
    |> Enum.filter(&filter_history/1)
    |> Enum.map(fn entry -> map_history(entry, local_timezone) end)
    |> Poison.encode!()
    |> InfinityAPS.write_data("history.json")
  end

  defp filter_history({entry, _})
       when entry in [:temp_basal, :temp_basal_duration, :bolus_wizard_estimate, :bolus_normal],
       do: true

  defp filter_history(_), do: false

  defp map_history(
         {:temp_basal, %{rate: rate, rate_type: rate_type, timestamp: timestamp}},
         local_timezone
       ) do
    %{
      "_type" => "TempBasal",
      "timestamp" => InfinityAPS.formatted_time(timestamp, local_timezone),
      "rate" => rate,
      "temp" => Atom.to_string(rate_type)
    }
  end

  defp map_history(
         {:temp_basal_duration, %{duration: duration, timestamp: timestamp}},
         local_timezone
       ) do
    %{
      "_type" => "TempBasalDuration",
      "timestamp" => InfinityAPS.formatted_time(timestamp, local_timezone),
      "duration (min)" => duration
    }
  end

  defp map_history(
         {:bolus_normal,
          %{
            programmed: programmed,
            duration: duration,
            amount: amount,
            type: type,
            timestamp: timestamp
          }},
         local_timezone
       ) do
    %{
      "_type" => "Bolus",
      "timestamp" => InfinityAPS.formatted_time(timestamp, local_timezone),
      "programmed" => programmed,
      "duration" => duration,
      "amount" => amount,
      "type" => Atom.to_string(type)
    }
  end

  defp map_history({:bolus_wizard_estimate, data}, local_timezone) do
    %{
      "_type" => "BolusWizard",
      "timestamp" => InfinityAPS.formatted_time(data.timestamp, local_timezone),
      "bg" => data.bg,
      "bg_target_high" => data.bg_target_high,
      "bg_target_low" => data.bg_target_low,
      "bolus_estimate" => data.bolus_estimate,
      "carb_input" => data.carbohydrates,
      "carb_ratio" => data.carb_ratio,
      "correction_estimate" => data.correction_estimate,
      "food_estimate" => data.food_estimate,
      "sensitivity" => data.insulin_sensitivity,
      "unabsorbed_insulin_total" => data.unabsorbed_insulin_total
    }
  end
end
