defmodule OAuthXYZ.Model.TransactionResponseTest do
  use OAuthXYZ.DataCase

  alias OAuthXYZ.Model.{Handle, Transaction, TransactionRequest, TransactionResponse}

  @request_params %{
    "resources" => [
      %{
        "actions" => [
          "read",
          "write",
          "dolphin"
        ],
        "locations" => [
          "https://server.example.net/",
          "https://resource.local/other"
        ],
        "datatypes" => [
          "metadata",
          "images"
        ]
      },
      "dolphin-metadata"
    ],
    "keys" => %{
      "proof" => "jwsd",
      "jwks" => %{
        "keys" => [
          %{
            "kty" => "RSA",
            "e" => "AQAB",
            "kid" => "xyz-1",
            "alg" => "RS256",
            "n" => "kOB5rR4Jv0GMeL...."
          }
        ]
      }
    },
    "interact" => %{
      "redirect" => true,
      "callback" => %{
        "uri" => "https://client.example.net/return/123455",
        "nonce" => "LKLTI25DK82FX4T4QFZC"
      }
    },
    "display" => %{
      "name" => "My Client Display Name",
      "uri" => "https://example.net/client"
    },
    "user" => %{
      "assertion" =>
        "eyJraWQiOiIxZTlnZGs3IiwiYWxnIjoiUlMyNTYifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg5NzYxMDAxIiwKICJhdWQiOiAiczZCaGRSa3F0MyIsCiAibm9uY2UiOiAibi0wUzZfV3pBMk1qIiwKICJleHAiOiAxMzExMjgxOTcwLAogImlhdCI6IDEzMTEyODA5NzAsCiAibmFtZSI6ICJKYW5lIERvZSIsCiAiZ2l2ZW5fbmFtZSI6ICJKYW5lIiwKICJmYW1pbHlfbmFtZSI6ICJEb2UiLAogImdlbmRlciI6ICJmZW1hbGUiLAogImJpcnRoZGF0ZSI6ICIwMDAwLTEwLTMxIiwKICJlbWFpbCI6ICJqYW5lZG9lQGV4YW1wbGUuY29tIiwKICJwaWN0dXJlIjogImh0dHA6Ly9leGFtcGxlLmNvbS9qYW5lZG9lL21lLmpwZyIKfQ.rHQjEmBqn9Jre0OLykYNnspA10Qql2rvx4FsD00jwlB0Sym4NzpgvPKsDjn_wMkHxcp6CilPcoKrWHcipR2iAjzLvDNAReF97zoJqq880ZD1bwY82JDauCXELVR9O6_B0w3K-E7yM2macAAgNCUwtik6SjoSUZRcf-O5lygIyLENx882p6MtmwaL1hd6qn5RZOQ0TLrOYu0532g9Exxcm-ChymrB4xLykpDj3lUivJt63eEGGN6DH5K6o33TcxkIjNrCD4XB1CKKumZvCedgHHF3IAK4dVEDSUoGlH9z4pP_eWYNXvqQOjGs-rDaQzUHl6cQQWNiDpWOl_lxXjQEvQ",
      "type" => "oidc_id_token"
    }
  }

  test "new" do
    # init
    handle = Handle.new(%{value: Ulid.generate(System.system_time(:millisecond)), type: :bearer})
    transaction_request = TransactionRequest.parse(@request_params)
    transaction = Transaction.new(%{handle: handle, request: transaction_request})
    transaction_response = TransactionResponse.new(transaction)

    assert transaction_response.handle == handle

    # wait
    wait = 30
    wait_transaction = %{transaction | wait: wait}
    transaction_response = TransactionResponse.new(wait_transaction)
    assert transaction_response.handle == handle
    assert transaction_response.wait == wait

    # redirect
    interact = transaction.interact
    interaction_url = "https://server.example.com/interact/4CF492MLVMSW9MKMXKHQ"
    interact = %{interact | url: interaction_url}
    server_nonce = "MBDOFXG4Y5CVJCX821LH"
    interact = %{interact | server_nonce: server_nonce}
    user_code = "A1BC-3DFF"
    interact = %{interact | user_code: user_code}
    user_code_url = "https://server.example.com/interact/device"
    interact = %{interact | user_code_url: user_code_url}

    redirect_transaction = %{transaction | interact: interact}
    transaction_response = TransactionResponse.new(redirect_transaction)
    assert transaction_response.handle == handle
    assert transaction_response.interaction_url == interaction_url
    assert transaction_response.server_nonce == server_nonce
    assert transaction_response.user_code == user_code
    assert transaction_response.user_code_url == user_code_url
  end
end
