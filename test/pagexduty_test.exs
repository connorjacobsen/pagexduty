defmodule PagexdutyTest do
  use ExUnit.Case, async: false

  setup do
    port = Application.get_env(:pagexduty, :bypass_port)
    bypass = Bypass.open(port: port)
    {:ok, bypass: bypass}
  end

  test "create_event creates a incident", %{bypass: bypass} do
    Pagexduty.Server.start_link("service_key")

    Bypass.expect_once(bypass, fn conn ->
      assert "/generic/2010-04-15/create_event.json" == conn.request_path
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, ~s({"status":"success","message":"Event processed","incident_key":"srv01/HTTP"}))
    end)

    response = Pagexduty.Server.trigger("My test incident", "srv01/HTTP", %{"detail" => "something"})
    assert "success" == response["status"]
    assert "srv01/HTTP" == response["incident_key"]
  end
end
