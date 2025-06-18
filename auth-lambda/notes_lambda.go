package main

import (
	"context"
	_ "encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

type Note struct {
	UserID  string `json:"user_id"`
	NoteID  string `json:"note_id"`
	Content string `json:"content"`
}

type Response struct {
	Message string `json:"message"`
	Error   string `json:"error,omitempty"`
}

func handler(ctx context.Context, note Note) (Response, error) {
	userTable := os.Getenv("USER_TABLE")
	notesTable := os.Getenv("NOTES_TABLE")

	if userTable == "" || notesTable == "" {
		return Response{Error: "Missing table env variables"}, nil
	}

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return Response{Error: fmt.Sprintf("config error: %v", err)}, nil
	}

	client := dynamodb.NewFromConfig(cfg)

	_, err = client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: aws.String(notesTable),
		Item: map[string]types.AttributeValue{
			"user_id":    &types.AttributeValueMemberS{Value: note.UserID},
			"note_id":    &types.AttributeValueMemberS{Value: note.NoteID},
			"content":    &types.AttributeValueMemberS{Value: note.Content},
			"created_at": &types.AttributeValueMemberS{Value: time.Now().Format(time.RFC3339)},
		},
	})
	if err != nil {
		return Response{Message: "Failed to save note", Error: err.Error()}, nil
	}

	return Response{Message: "Note saved successfully"}, nil
}

func main() {
	lambda.Start(handler)
}
