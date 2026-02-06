require "swagger_helper"

RSpec.describe "Tasks API", type: :request do
  let(:user) { User.create!(username: "nando", password_digest: BCrypt::Password.create("123456")) }
  let(:jwt_security) { JwtSecurity.new }
  let(:access_token) { jwt_security.generate_access_token(user.id) }
  let(:Authorization) { "Bearer #{access_token}" }

  path "/tasks" do
    post "Cria uma nova task" do
      tags "Tasks"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[title due_date priority],
        properties: {
          title: { type: :string, example: "Comprar pão" },
          description: { type: :string, example: "Ir à padaria e comprar pão francês" },
          due_date: { type: :string, format: "date", example: "2026-02-10" },
          priority: { type: :integer, example: 3, minimum: 1, maximum: 5 }
        }
      }

      response "201", "criado" do
        let(:payload) do
          {
            title: "Comprar pão",
            description: "Ir à padaria",
            due_date: "2026-02-10",
            priority: 3
          }
        end

        schema type: :object,
               required: %w[id title description due_date priority completed user_id created_at updated_at],
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 description: { type: :string, nullable: true },
                 due_date: { type: :string, format: "date" },
                 priority: { type: :integer },
                 completed: { type: :boolean },
                 user_id: { type: :integer },
                 created_at: { type: :string, format: "date-time" },
                 updated_at: { type: :string, format: "date-time" }
               }

        run_test!
      end

      response "422", "erro de validação" do
        let(:payload) do
          {
            title: "AB",
            due_date: nil,
            priority: 10
          }
        end

        schema type: :object,
               required: %w[errors],
               properties: {
                 errors: {
                   type: :object,
                   additionalProperties: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }

        run_test!
      end

      response "401", "não autorizado" do
        let(:Authorization) { "Bearer token_invalido" }
        let(:payload) do
          {
            title: "Comprar pão",
            due_date: "2026-02-10",
            priority: 3
          }
        end

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string } }

        run_test!
      end
    end

    get "Lista todas as tasks do usuário autenticado" do
      tags "Tasks"
      produces "application/json"
      security [Bearer: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: "Número da página", example: 1
      parameter name: :limit, in: :query, type: :integer, required: false, description: "Quantidade de itens por página", example: 20

      response "200", "ok" do
        let(:page) { 1 }
        let(:limit) { 20 }

        before do
          Task.create!(
            title: "Task 1",
            description: "Descrição 1",
            due_date: "2026-02-10",
            priority: 3,
            user_id: user.id
          )
          Task.create!(
            title: "Task 2",
            description: "Descrição 2",
            due_date: "2026-02-11",
            priority: 5,
            user_id: user.id
          )
        end

        schema type: :object,
               required: %w[data pagination],
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %w[id title description due_date priority completed user_id created_at updated_at],
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       description: { type: :string, nullable: true },
                       due_date: { type: :string, format: "date" },
                       priority: { type: :integer },
                       completed: { type: :boolean },
                       user_id: { type: :integer },
                       created_at: { type: :string, format: "date-time" },
                       updated_at: { type: :string, format: "date-time" }
                     }
                   }
                 },
                 pagination: {
                   type: :object,
                   required: %w[current_page per_page total_pages total_count],
                   properties: {
                     current_page: { type: :integer },
                     per_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }

        run_test!
      end

      response "401", "não autorizado" do
        let(:Authorization) { "Bearer token_invalido" }

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string } }

        run_test!
      end
    end
  end

  path "/tasks/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID da task"

    get "Retorna uma task específica" do
      tags "Tasks"
      produces "application/json"
      security [Bearer: []]

      response "200", "ok" do
        let(:task) do
          Task.create!(
            title: "Minha task",
            description: "Descrição da task",
            due_date: "2026-02-10",
            priority: 4,
            user_id: user.id
          )
        end
        let(:id) { task.id }

        schema type: :object,
               required: %w[id title description due_date priority completed user_id created_at updated_at],
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 description: { type: :string, nullable: true },
                 due_date: { type: :string, format: "date" },
                 priority: { type: :integer },
                 completed: { type: :boolean },
                 user_id: { type: :integer },
                 created_at: { type: :string, format: "date-time" },
                 updated_at: { type: :string, format: "date-time" }
               }

        run_test!
      end

      response "404", "task não encontrada" do
        let(:id) { 99999 }

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string, example: "Task not found" } }

        run_test!
      end

      response "401", "não autorizado" do
        let(:Authorization) { "Bearer token_invalido" }
        let(:id) { 1 }

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string } }

        run_test!
      end
    end

    put "Atualiza uma task" do
      tags "Tasks"
      consumes "application/json"
      produces "application/json"
      security [Bearer: []]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: "Título atualizado" },
          description: { type: :string, example: "Descrição atualizada" },
          due_date: { type: :string, format: "date", example: "2026-02-15" },
          priority: { type: :integer, example: 5, minimum: 1, maximum: 5 },
          completed: { type: :boolean, example: true }
        }
      }

      response "200", "ok" do
        let(:task) do
          Task.create!(
            title: "Task original",
            description: "Descrição original",
            due_date: "2026-02-10",
            priority: 3,
            user_id: user.id
          )
        end
        let(:id) { task.id }
        let(:payload) do
          {
            title: "Task atualizada",
            completed: true
          }
        end

        schema type: :object,
               required: %w[id title description due_date priority completed user_id created_at updated_at],
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 description: { type: :string, nullable: true },
                 due_date: { type: :string, format: "date" },
                 priority: { type: :integer },
                 completed: { type: :boolean },
                 user_id: { type: :integer },
                 created_at: { type: :string, format: "date-time" },
                 updated_at: { type: :string, format: "date-time" }
               }

        run_test!
      end

      response "404", "task não encontrada" do
        let(:id) { 99999 }
        let(:payload) { { title: "Novo título" } }

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string, example: "Task not found" } }

        run_test!
      end

      response "422", "erro de validação" do
        let(:task) do
          Task.create!(
            title: "Task original",
            due_date: "2026-02-10",
            priority: 3,
            user_id: user.id
          )
        end
        let(:id) { task.id }
        let(:payload) { { title: "AB" } }

        schema type: :object,
               required: %w[errors],
               properties: {
                 errors: {
                   type: :object,
                   additionalProperties: {
                     type: :array,
                     items: { type: :string }
                   }
                 }
               }

        run_test!
      end

      response "401", "não autorizado" do
        let(:Authorization) { "Bearer token_invalido" }
        let(:id) { 1 }
        let(:payload) { { title: "Novo título" } }

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string } }

        run_test!
      end
    end

    delete "Remove uma task" do
      tags "Tasks"
      produces "application/json"
      security [Bearer: []]

      response "200", "ok" do
        let(:task) do
          Task.create!(
            title: "Task a ser deletada",
            due_date: "2026-02-10",
            priority: 3,
            user_id: user.id
          )
        end
        let(:id) { task.id }

        schema type: :object,
               required: %w[message],
               properties: {
                 message: { type: :string, example: "Task deleted successfully" }
               }

        run_test!
      end

      response "404", "task não encontrada" do
        let(:id) { 99999 }

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string, example: "Task not found" } }

        run_test!
      end

      response "401", "não autorizado" do
        let(:Authorization) { "Bearer token_invalido" }
        let(:id) { 1 }

        schema type: :object,
               required: %w[error],
               properties: { error: { type: :string } }

        run_test!
      end
    end
  end
end
