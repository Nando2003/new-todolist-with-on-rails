# NEW-TODOLIST-WITH-ON-RAILS

1. Copy .env.example to .env and set your environment variables:
   ```bash
   cp .env.example .env
   ```

2. Inialize application:
   ```bash
   docker compose up --build
   ```

3. Create database:
   ```bash
   docker compose exec app rails db:migrate
   ```

4. Access the application at http://localhost:3000/api-docs

## Generate API documentation

To generate API documentation, run the following command:
    ```bash
    docker compose exec app rake rswag:specs:swaggerize
    ```