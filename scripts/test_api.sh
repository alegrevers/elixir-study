#!/bin/bash

# Script para testar a API Library
# Execute: chmod +x scripts/test_api.sh && ./scripts/test_api.sh

BASE_URL="http://localhost:4000/api"

echo "========================================="
echo "  Library API - Testes Manuais"
echo "========================================="
echo ""

# 1. Listar todos os livros
echo "1. GET /api/books - Listar todos os livros"
curl -s -X GET "$BASE_URL/books" | jq '.'
echo ""
echo ""

# 2. Criar um novo livro
echo "2. POST /api/books - Criar novo livro"
BOOK_DATA='{
  "book": {
    "title": "Domain-Driven Design",
    "author": "Eric Evans",
    "isbn": "9780321125217",
    "year": 2003
  }
}'
RESPONSE=$(curl -s -X POST "$BASE_URL/books" \
  -H "Content-Type: application/json" \
  -d "$BOOK_DATA")
echo $RESPONSE | jq '.'
BOOK_ID=$(echo $RESPONSE | jq -r '.data.id')
echo "Livro criado com ID: $BOOK_ID"
echo ""
echo ""

# 3. Buscar livro específico
echo "3. GET /api/books/$BOOK_ID - Buscar livro por ID"
curl -s -X GET "$BASE_URL/books/$BOOK_ID" | jq '.'
echo ""
echo ""

# 4. Emprestar livro
echo "4. POST /api/books/$BOOK_ID/borrow - Emprestar livro"
curl -s -X POST "$BASE_URL/books/$BOOK_ID/borrow" | jq '.'
echo ""
echo ""

# 5. Tentar emprestar novamente (deve falhar)
echo "5. POST /api/books/$BOOK_ID/borrow - Tentar emprestar novamente (erro esperado)"
curl -s -X POST "$BASE_URL/books/$BOOK_ID/borrow" | jq '.'
echo ""
echo ""

# 6. Devolver livro
echo "6. POST /api/books/$BOOK_ID/return - Devolver livro"
curl -s -X POST "$BASE_URL/books/$BOOK_ID/return" | jq '.'
echo ""
echo ""

# 7. Atualizar livro
echo "7. PUT /api/books/$BOOK_ID - Atualizar título"
UPDATE_DATA='{
  "book": {
    "title": "Domain-Driven Design: Tackling Complexity"
  }
}'
curl -s -X PUT "$BASE_URL/books/$BOOK_ID" \
  -H "Content-Type: application/json" \
  -d "$UPDATE_DATA" | jq '.'
echo ""
echo ""

# 8. Ver estatísticas
echo "8. GET /api/stats - Ver estatísticas do GenServer"
curl -s -X GET "$BASE_URL/stats" | jq '.'
echo ""
echo ""

# 9. Ver logs no MongoDB
echo "9. GET /api/logs - Ver logs (MongoDB)"
curl -s -X GET "$BASE_URL/logs" | jq '.'
echo ""
echo ""

# 10. Logs de um livro específico
echo "10. GET /api/logs/book/$BOOK_ID - Logs do livro criado"
curl -s -X GET "$BASE_URL/logs/book/$BOOK_ID" | jq '.'
echo ""
echo ""

# 11. Deletar livro
echo "11. DELETE /api/books/$BOOK_ID - Deletar livro"
curl -s -X DELETE "$BASE_URL/books/$BOOK_ID" -w "\nStatus: %{http_code}\n"
echo ""
echo ""

# 12. Tentar buscar livro deletado (deve retornar 404)
echo "12. GET /api/books/$BOOK_ID - Buscar livro deletado (erro esperado)"
curl -s -X GET "$BASE_URL/books/$BOOK_ID" | jq '.'
echo ""
echo ""

# 13. Estatísticas finais
echo "13. GET /api/stats - Estatísticas finais"
curl -s -X GET "$BASE_URL/stats" | jq '.'
echo ""
echo ""

echo "========================================="
echo "  Testes concluídos!"
echo "========================================="