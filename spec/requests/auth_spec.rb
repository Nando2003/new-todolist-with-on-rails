require "swagger_helper"

RSpec.describe "Auth API", type: :request do
  path "/signup" do
    post "Cria um usuário e retorna tokens" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[username password],
        properties: {
          username: { type: :string, example: "nando" },
          password: { type: :string, example: "123456" }
        }
      }

      response "201", "criado" do
        let(:payload) { { username: "nando", password: "123456" } }

        schema type: :object,
               required: %w[access_token refresh_token],
               properties: {
                 access_token: { type: :string },
                 refresh_token: { type: :string }
               }

        run_test!
      end

      response "422", "erro de validação" do
        let(:payload) { { username: "", password: "" } }

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
    end
  end

  path "/login" do
    post "Login e retorna tokens" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[username password],
        properties: {
          username: { type: :string, example: "nando" },
          password: { type: :string, example: "123456" }
        }
      }

      response "200", "ok" do
        let(:payload) { { username: "nando", password: "123456" } }

        schema type: :object,
               required: %w[access_token refresh_token],
               properties: {
                 access_token: { type: :string },
                 refresh_token: { type: :string }
               }

        # garante que o usuário existe antes do login
        before do
          hashed = BCrypt::Password.create("123456")
          User.create!(username: "nando", password_digest: hashed)
        end

        run_test!
      end

      response "401", "credenciais inválidas" do
        let(:payload) { { username: "nando", password: "errada" } }

        schema type: :object,
               required: %w[error],
               properties: {
                 error: { type: :string, example: "Invalid username or password" }
               }

        before do
          hashed = BCrypt::Password.create("123456")
          User.create!(username: "nando", password_digest: hashed)
        end

        run_test!
      end
    end
  end

  path "/refresh" do
    post "Gera um novo access token a partir do refresh token" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[refresh_token],
        properties: {
          refresh_token: { type: :string, example: "REFRESH_TOKEN_AQUI" }
        }
      }

      response "200", "ok" do
        schema type: :object,
               required: %w[access_token],
               properties: {
                 access_token: { type: :string }
               }

        let(:payload) do
          # cria usuário e gera refresh token real usando o mesmo JwtSecurity do app
          user = User.create!(username: "nando", password_digest: BCrypt::Password.create("123456"))
          refresh = JwtSecurity.new.generate_refresh_token(user.id)
          { refresh_token: refresh }
        end

        run_test!
      end

      response "401", "refresh token inválido" do
        let(:payload) { { refresh_token: "token_invalido" } }

        schema type: :object,
               required: %w[error],
               properties: {
                 error: { type: :string, example: "Invalid refresh token" }
               }

        run_test!
      end
    end
  end
end
