defmodule WebServer do
  @moduledoc """
  $ iex 22-socket-server.exs
  	Then visit http://localhost:3000. You should see something like:
  	Your User-Agent is: Mozilla/5.0 (X11; Linux x86_64; rv:25.0) Gecko/20100101 Firefox/25.0
  """

  def server do
    {:ok, lsock} = :gen_tcp.listen(3000, [:binary, {:packet, 0}, {:active, false}])
    accept_connection(lsock)
  end

  def accept_connection(lsock) do
    {:ok, sock} = :gen_tcp.accept(lsock)

    case handle_request(sock) do
      :closed ->
        accept_connection(lsock)

      request ->
        IO.puts(inspect(request))

        msg =
          case extract_user_agent(request) do
            nil -> "You don't have a user-agent!"
            ua -> "Your User-Agent is: #{ua}"
          end

        :gen_tcp.send(sock, :erlang.bitstring_to_list("HTTP/1.1 200 OK\r\n\r\n" <> msg <> "\r\n"))
        :gen_tcp.close(sock)
        accept_connection(lsock)
    end
  end

  def handle_request(sock, request \\ '') do
		case :gen_tcp.recv(sock, 0)) do
			{:ok, b} ->
				if Regex.match?(~r/\r\n\r\n/, b) do
					:erlang.list_to_bitstring([request, b])
				else
					handle_request(sock, [request, b])
				end
			_ ->
				:closed
		end
  end
end
