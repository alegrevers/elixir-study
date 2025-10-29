# Library API - Exemplo Prático Elixir

API REST de gerenciamento de biblioteca demonstrando conceitos fundamentais do Elixir:
- **Pattern Matching**: Usado extensivamente em funções, validações e tratamento de erros
- **Supervisor**: Gerenciamento de processos com recuperação automática de falhas
- **Modelo de Atores**: GenServer para cache de estatísticas com comunicação por mensagens

## Stack

- **Elixir** 1.14+
- **Phoenix Framework** para API REST
- **PostgreSQL** para dados relacionais (livros)
- **MongoDB** para logs não relacionais
- **Ecto** para ORM e migrations
- **ExUnit** para testes

## Estrutura do Projeto

```
library_api/
├── lib/
│   ├── library_api/
│   │   ├── application.ex          # Supervisor principal
│   │   ├── repo.ex                 # PostgreSQL repo
│   │   ├── books.ex                # Context de livros (pattern matching)
│   │   ├── logs.ex                 # Context de logs MongoDB
│   │   ├── stats_cache.ex          # GenServer (modelo de atores)
│   │   └── books/
│   │       └── book.ex             # Schema Ecto
│   └── library_api_web/
│       ├── endpoint.ex              # Phoenix endpoint
│       ├── router.ex                # Rotas da API
│       └── controllers/
│           ├── book_controller.ex   # CRUD de livros
│           ├── log_controller.ex    # Consulta de logs
│           └── stats_controller.ex  # Estatísticas
├── test/
│   ├── library_api/
│   │   ├── books_test.exs          # Testes unitários
│   │   └── stats_cache_test.exs    # Testes do GenServer
│   └── library_api_web/
│       └── controllers/
│           └── book_controller_test.exs  # Testes de integração
├── priv/repo/
│   ├── migrations/
│   │   └── 20241028_create_books.exs
│   └── seeds.exs                    # Dados fake
└── config/
    ├── config.exs
    ├── dev.exs
    └── test.exs
```

## Setup Local

### Pré-requisitos

```bash
# Elixir e Erlang
asdf install elixir 1.14.0
asdf install erlang 25.0

# PostgreSQL (sem Docker)
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo -u postgres createuser -s $USER

# MongoDB (sem Docker)
sudo apt-get install mongodb
sudo systemctl start mongodb
```

### Instalação

```bash
# Clone o repositório
git clone <seu-repo>
cd library_api

# Instale dependências
mix deps.get

# Configure o banco PostgreSQL
mix ecto.create
mix ecto.migrate

# Popule dados fake
mix run priv/repo/seeds.exs
```

### Executar a aplicação

```bash
# Inicia o servidor na porta 4000
mix phx.server
```

### Executar testes

```bash
# Todos os testes
mix test

# Testes específicos
mix test test/library_api/books_test.exs
mix test test/library_api/stats_cache_test.exs
mix test test/library_api_web/controllers/book_controller_test.exs

# Com cobertura
mix test --cover
```

## Conceitos Demonstrados

### 1. Pattern Matching

Usado em todo o código para destructuring e controle de fluxo:

```elixir
# lib/library_api/books.ex

# Pattern matching no retorno de funções
def get_book(id) do
  case Repo.get(Book, id) do
    %Book{} = book -> {:ok, book}    # Match quando encontra
    nil -> {:error, :not_found}       # Match quando não encontra
  end
end

# Pattern matching em parâmetros de função
def list_books_by_availability(true), do: # ...
def list_books_by_availability(false), do: # ...

# Pattern matching com guards
def borrow_book(id) do
  with {:ok, %Book{available: true} = book} <- get_book(id) do
    # ...
  end
end
```

### 2. Supervisor

Árvore de supervisão definida em `application.ex`:

```elixir
# lib/library_api/application.ex

def start(_type, _args) do
  children = [
    LibraryApi.Repo,           # PostgreSQL
    {Mongo, [name: :mongo]},   # MongoDB
    LibraryApi.StatsCache,     # GenServer
    LibraryApiWeb.Endpoint     # Phoenix
  ]

  # Se um processo falha, só ele é reiniciado
  opts = [strategy: :one_for_one, name: LibraryApi.Supervisor]
  Supervisor.start_link(children, opts)
end
```

### 3. Modelo de Atores (GenServer)

Cache de estatísticas como ator isolado:

```elixir
# lib/library_api/stats_cache.ex

# Comunicação síncrona (call)
def get_stats do
  GenServer.call(__MODULE__, :get_stats)
end

# Comunicação assíncrona (cast)
def increment_operation(operation_type) do
  GenServer.cast(__MODULE__, {:increment, operation_type})
end

# Estado imutável - cada update cria novo estado
def handle_cast({:increment, :book_created}, state) do
  new_state = Map.update!(state, :books_created, &(&1 + 1))
  {:noreply, new_state}
end
```

## API Endpoints

### Livros

```bash
# Listar todos os livros
GET /api/books

# Buscar livro por ID
GET /api/books/:id

# Criar novo livro
POST /api/books
{
  "book": {
    "title": "Clean Code",
    "author": "Robert Martin",
    "isbn": "9780132350884",
    "year": 2008
  }
}

# Atualizar livro
PUT /api/books/:id
{
  "book": {
    "title": "Novo título"
  }
}

# Deletar livro
DELETE /api/books/:id

# Emprestar livro
POST /api/books/:id/borrow

# Devolver livro
POST /api/books/:id/return
```

### Logs

```bash
# Listar todos os logs (MongoDB)
GET /api/logs

# Filtrar logs por ação
GET /api/logs?action=book_created

# Logs de um livro específico
GET /api/logs/book/:book_id
```

### Estatísticas

```bash
# Obter estatísticas (do GenServer)
GET /api/stats

# Resposta
{
  "data": {
    "books_created": 10,
    "books_updated": 5,
    "books_deleted": 2,
    "books_borrowed": 8,
    "books_returned": 6,
    "last_reset": "2024-10-28T10:30:00Z"
  }
}
```

## Dados Fake (Seeds)

O arquivo `seeds.exs` já popula o banco com 10 livros de programação:

- Clean Code (Robert Martin)
- The Pragmatic Programmer (David Thomas)
- Design Patterns (Erich Gamma)
- Refactoring (Martin Fowler)
- Introduction to Algorithms (Cormen)
- Elixir in Action (Saša Jurić)
- Programming Elixir (Dave Thomas)
- Functional Programming in Scala (Paul Chiusano)
- SICP (Harold Abelson)
- The Art of Computer Programming (Donald Knuth)

## Arquitetura

### PostgreSQL (Dados Relacionais)
- Armazena informações dos livros
- Schema com validações via Ecto
- Índices para performance
- Constraints de unicidade (ISBN)

### MongoDB (Logs)
- Registros de todas as operações
- Escrita assíncrona (não bloqueia operações)
- Queries flexíveis sem schema rígido

### GenServer (Cache em Memória)
- Contadores de operações em tempo real
- Estado isolado em processo dedicado
- Acesso concorrente seguro
- Supervisionado automaticamente

## Testes

### Unitários
- `books_test.exs`: Testa lógica de negócio e pattern matching
- `stats_cache_test.exs`: Testa GenServer e modelo de atores

### Integração
- `book_controller_test.exs`: Testa API REST completa
- Verifica integração entre controllers, contexts e GenServer

```bash
# Executar testes com output detalhado
mix test --trace

# Apenas testes assíncronos
mix test --only async

# Excluir testes lentos
mix test --exclude slow
```

## Comandos Úteis

```bash
# Console interativo
iex -S mix

# Recompilar código
recompile()

# Resetar banco
mix ecto.reset

# Verificar formato do código
mix format

# Analisar código
mix credo
```
