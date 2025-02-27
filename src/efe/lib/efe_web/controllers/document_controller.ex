defmodule EFEWeb.DocumentController do
  use EFEWeb, :controller

  alias EFE.Documents
  alias EFE.Documents.Document

  action_fallback EFEWeb.FallbackController

  def index(conn, _params) do
    documents = Documents.list_documents()
    render(conn, :index, documents: documents)
  end

  def create(conn, %{"document" => document_params}) do
    with {:ok, %Document{} = document} <- Documents.create_document(document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, document: document)
    end
  end

  def show(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    render(conn, :show, document: document)
  end

  def update(conn, %{"id" => id, "document" => document_params}) do
    document = Documents.get_document!(id)

    with {:ok, %Document{} = document} <- Documents.update_document(document, document_params) do
      render(conn, :show, document: document)
    end
  end

  def delete(conn, %{"id" => id}) do
    document = Documents.get_document!(id)

    with {:ok, %Document{}} <- Documents.delete_document(document) do
      send_resp(conn, :no_content, "")
    end
  end

  def bytes(conn, %{"path" => path}) do
    with {:ok, path} <- safe_path(path) do
      if File.regular?(path) do
        send_download(conn, {:file, path}, disposition: :inline)
      else
        send_resp(conn, :not_found, "")
      end
    else
      :error -> send_resp(conn, :forbidden, "")
    end
  end

  def write(conn, %{"path" => path}) do
    with {:ok, path} <- safe_path(path) do
      {:ok, body, conn} = read_body(conn)
      File.write!(path, body, [:write])
      send_resp(conn, :ok, "")
    else
      :error -> send_resp(conn, :forbidden, "")
    end
  end

  def safe_path(path) do
    docroot = Application.fetch_env!(:efe, :docroot)

    path
    |> Path.join()
    |> Path.safe_relative(docroot)
    |> case do
      {:ok, path} ->
        {:ok, Path.join(docroot, path)}

      :error ->
        :error
    end
  end
end
