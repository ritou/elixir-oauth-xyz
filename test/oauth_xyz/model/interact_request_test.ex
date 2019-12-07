defmodule OAuthXYZ.Model.InteractRequestTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.InteractRequest

  test "constructor" do
    uri = "https://client.example.net/return/123455"
    nonce = "LKLTI25DK82FX4T4QFZC"

    interact =
      InteractRequest.parse(%{
        "redirect" => true,
        "callback" => %{
          "uri" => uri,
          "nonce" => nonce
        }
      })

    assert interact.redirect

    assert interact.callback == %{
             "uri" => uri,
             "nonce" => nonce
           }

    refute interact.user_code
    refute interact.didcomm
    refute interact.didcomm_query

    interact =
      InteractRequest.parse(%{
        "user_code" => true
      })

    refute interact.redirect
    refute interact.callback
    assert interact.user_code == true
    refute interact.didcomm
    refute interact.didcomm_query

    interact =
      InteractRequest.parse(%{
        "didcomm" => true
      })

    refute interact.redirect
    refute interact.callback
    refute interact.user_code
    assert interact.didcomm == true
    refute interact.didcomm_query

    interact =
      InteractRequest.parse(%{
        "didcomm_query" => true
      })

    refute interact.redirect
    refute interact.callback
    refute interact.user_code
    refute interact.didcomm
    assert interact.didcomm_query == true
  end
end
