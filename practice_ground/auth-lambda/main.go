package main

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	cognito "github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider/types"
)

var (
	client       *cognito.Client
	clientID     string
	clientSecret string
	userPoolID   string
)

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load SDK config: %v", err)
	}
	client = cognito.NewFromConfig(cfg)

	clientID = os.Getenv("CLIENT_ID")
	clientSecret = os.Getenv("CLIENT_SECRET")
	userPoolID = os.Getenv("USER_POOL_ID")
	if clientID == "" || userPoolID == "" {
		log.Fatal("CLIENT_ID or USER_POOL_ID not set in environment variables")
	}
}

type AuthRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// Calculate Cognito SECRET_HASH for given username
func calculateSecretHash(username, clientID, clientSecret string) string {
	mac := hmac.New(sha256.New, []byte(clientSecret))
	mac.Write([]byte(username + clientID))
	return base64.StdEncoding.EncodeToString(mac.Sum(nil))
}

func handler(ctx context.Context, req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	var input AuthRequest
	if err := json.Unmarshal([]byte(req.Body), &input); err != nil {
		return response(http.StatusBadRequest, "Invalid JSON: "+err.Error()), nil
	}

	switch req.Path {
	case "/login":
		return login(&input)
	case "/register":
		return register(&input)
	default:
		return response(http.StatusNotFound, "Route not found"), nil
	}
}

func login(input *AuthRequest) (*events.APIGatewayProxyResponse, error) {
	//secretHash := calculateSecretHash(input.Email, clientID, clientSecret)

	authInput := &cognito.InitiateAuthInput{
		AuthFlow: types.AuthFlowTypeUserPasswordAuth,
		ClientId: aws.String(clientID),
		AuthParameters: map[string]string{
			"USERNAME": input.Email,
			"PASSWORD": input.Password,
		},
	}

	authResp, err := client.InitiateAuth(context.TODO(), authInput)
	if err != nil {
		log.Printf("login failed: %v", err)
		return response(http.StatusUnauthorized, "Login failed: "+err.Error()), nil
	}

	body, _ := json.Marshal(map[string]string{
		"access_token":  aws.ToString(authResp.AuthenticationResult.AccessToken),
		"id_token":      aws.ToString(authResp.AuthenticationResult.IdToken),
		"refresh_token": aws.ToString(authResp.AuthenticationResult.RefreshToken),
	})

	return &events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(body),
	}, nil
}

//func calculateSecretHash(username, clientID, clientSecret string) string {
//	if clientSecret == "" {
//		return ""
//	}
//	mac := hmac.New(sha256.New, []byte(clientSecret))
//	mac.Write([]byte(username + clientID))
//	return base64.StdEncoding.EncodeToString(mac.Sum(nil))
//}

func register(input *AuthRequest) (*events.APIGatewayProxyResponse, error) {
	signUpInput := &cognito.SignUpInput{
		ClientId: aws.String(clientID),
		Username: aws.String(input.Email),
		Password: aws.String(input.Password),
		UserAttributes: []types.AttributeType{
			{
				Name:  aws.String("email"),
				Value: aws.String(input.Email),
			},
		},
	}

	if clientSecret != "" {
		secretHash := calculateSecretHash(input.Email, clientID, clientSecret)
		signUpInput.SecretHash = aws.String(secretHash)
	}

	_, err := client.SignUp(context.TODO(), signUpInput)
	if err != nil {
		log.Printf("registration failed: %v", err)
		return response(http.StatusBadRequest, "Registration failed: "+err.Error()), nil
	}

	return response(http.StatusCreated, "User registered successfully"), nil
}

func response(status int, body string) *events.APIGatewayProxyResponse {
	return &events.APIGatewayProxyResponse{
		StatusCode: status,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       fmt.Sprintf(`{"message": "%s"}`, body),
	}
}

func main() {
	lambda.Start(handler)
}
