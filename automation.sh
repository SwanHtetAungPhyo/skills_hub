#!/usr/bin/env bash

log() {
  printf '[%s] [INFO] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

main() {
  pwd

  if [ -f "main.go" ]; then
    log "File main.go exists. Building..."
    GOOS=linux GOARCH=amd64 go build -o bootstrap main.go
    zip auth_lambda.zip bootstrap
    mv auth_lambda.zip ../aws/auth_lambda.zip
    log "Build and packaging complete."
  else
    log "File main.go does not exist. Trying auth-lambda directory..."

    if [ -d "auth-lambda" ] && [ -f "auth-lambda/main.go" ]; then
      cd auth-lambda || exit 1
      log "Entered auth-lambda directory. Building..."
      GOOS=linux GOARCH=amd64 go build -o bootstrap main.go
      zip auth_lambda.zip bootstrap
      mv auth_lambda.zip ../aws/auth_lambda.zip
      log "Build and packaging complete from auth-lambda."
      GOOS=linux GOARCH=amd64 go build -o bootstrap auth_lambda.go
      zip notes_lambda.zip bootstrap
      mv notes_lambda.zip ../aws/notes_lambda.zip
      log "Packing notes lambda zip and move to the terraform"
      log "Destroying the old infrastructure"
      cd ../aws/ || exit 1
      terraform destroy
      ./terraform.sh
      api_url=$(terraform output -raw api_invoke_url)
      user_pool_id=$(terraform output -raw cognito_user_pool_id)
      # shellcheck disable=SC2034
      lambda_arn=$(terraform output -raw lambda_auth_arn)
      local email="swanhtetaungp@gmail.com"
      local password="SwanHtet12@"
      log lambda_arn
      log api_url
      log user_pool_id
      test_register "$api_url" "$email" "$password"
      force_admin_confirm "$user_pool_id" "$email"
      test_login "$api_url"
    else
      log "main.go not found in current or auth-lambda directory."
    fi
  fi
}

test_register() {
  local api_url=$1
  local email=$2
  local password=$3

  curl -X POST \
    "$api_url/register" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"$email\", \"password\": \"$password\"}" | jq .
}

force_admin_confirm(){
  local user_pool_id=$1
  local email=$1

  aws cognito-idp admin-confirm-singup \
  --user-pool-id "$user_pool_id" \
  --username "$email"
}

test_login(){
  local api_url=$1
  local email=$2
  local password=$3
  curl -X POST \
    "$api_url/register" \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"$email\", \"password\": \"$password\"}" | jq .
}
main
