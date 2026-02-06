require "swagger_helper"

RSpec.describe "Users API", type: :request do
  path "/me" do
    get "Retorna o usuário autenticado" do
      tags "Users"
      produces "application/json"

      security [Bearer: []]

      response "200", "ok" do
        schema type: :object,
               required: %w[id username created_at updated_at],
               properties: {
                 id: { type: :integer },
                 username: { type: :string },
                 created_at: { type: :string, format: "date-time" },
                 updated_at: { type: :string, format: "date-time" }
               }

        run_test!
      end

      response "401", "não autorizado" do
        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string } }

        run_test!
      end
    end
  end
end
