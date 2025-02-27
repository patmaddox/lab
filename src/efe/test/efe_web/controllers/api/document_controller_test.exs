defmodule EFEWeb.API.DocumentControllerTest do
  use EFEWeb.ConnCase

  import EFE.DocumentsFixtures

  alias EFE.Documents.Document

  @create_attrs %{
    file_name: "some file_name"
  }
  @update_attrs %{
    file_name: "some updated file_name"
  }
  @invalid_attrs %{file_name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all documents", %{conn: conn} do
      conn = get(conn, ~p"/api/documents")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "read" do
    test "returns the bytes", %{conn: conn} do
      conn = get(conn, ~p"/api/documents/read/subdir/foo.txt")

      assert response(conn, 200) == "hello foo\n"
    end

    test "404", %{conn: conn} do
      conn = get(conn, ~p"/api/documents/read/missing.txt")

      assert response(conn, 404)
    end

    test "error on path traversal", %{conn: conn} do
      conn = get(conn, ~p"/api/documents/read/../foo.txt")

      assert response(conn, 403)
    end
  end

  describe "write (status 1 = no-op)" do
    setup do
      docroot = Application.fetch_env!(:efe, :docroot)
      out_file = Path.join(docroot, "out.txt")
      if File.exists?(out_file), do: File.rm!(out_file)
      %{out_file: out_file}
    end

    test "returns success, does not modify file", %{conn: conn, out_file: out_file} do
      conn = post(conn, ~p"/api/documents/write/out.txt", %{status: 1})
      assert json_response(conn, 200) == %{"error" => 0}
      refute File.exists?(out_file)
    end
  end

  describe "write (status 2 = write)" do
    setup do
      docroot = Application.fetch_env!(:efe, :docroot)
      out_file = Path.join(docroot, "out.txt")
      if File.exists?(out_file), do: File.rm!(out_file)
      %{out_file: out_file}
    end

    test "writes the bytes", %{conn: conn, out_file: out_file} do
      Req.Test.verify_on_exit!()

      Req.Test.expect(EFEWeb.API.DocumentController, fn c ->
        assert Plug.Conn.request_url(c) == "http://doc-location/my-doc.txt"
        Req.Test.text(c, "this is a new foo")
      end)

      conn =
        post(conn, ~p"/api/documents/write/out.txt", %{
          status: 2,
          url: "http://doc-location/my-doc.txt"
        })

      assert json_response(conn, 200) == %{"error" => 0}
      assert File.read!(out_file) == "this is a new foo"
    end

    test "error on path traversal", %{conn: conn} do
      conn =
        post(conn, ~p"/api/documents/write/../out.txt", %{
          status: 2,
          url: "http://doc-location/my-doc.txt"
        })

      assert response(conn, 403)
    end
  end

  describe "create document" do
    test "renders document when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/documents", document: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/documents/#{id}")

      assert %{
               "id" => ^id,
               "file_name" => "some file_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/documents", document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update document" do
    setup [:create_document]

    test "renders document when data is valid", %{
      conn: conn,
      document: %Document{id: id} = document
    } do
      conn = put(conn, ~p"/api/documents/#{document}", document: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/documents/#{id}")

      assert %{
               "id" => ^id,
               "file_name" => "some updated file_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, document: document} do
      conn = put(conn, ~p"/api/documents/#{document}", document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete document" do
    setup [:create_document]

    test "deletes chosen document", %{conn: conn, document: document} do
      conn = delete(conn, ~p"/api/documents/#{document}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/documents/#{document}")
      end
    end
  end

  defp create_document(_) do
    document = document_fixture()
    %{document: document}
  end
end
