defmodule AuthService.JSONUtils do
  @moduledoc """
  JSON Utilities
  """

  @doc """
  Extend BSON to encode MongoDB ObjectIds to string
  """
  # Defining an implementation for the Json.Encode for BSON.ObjectId
  defimpl Jason.Encoder, for: BSON.ObjectId do
    # Implementing a custom encode function
    def encode(id, options) do
      # Converting the binary id to a string
      BSON.ObjectId.encode!(id)
      # Encoding the string to JSON
      |> Jason.Encoder.encode(options)
    end

    def normaliseMongoI(document) do
      document
      # Set the id property to the value if _id
      |> Map.put('id', document["_id"])
      # Delete the _id property
      |> Map.delete("_id")
    end
  end
end