package main

import (
	"github.com/gofiber/fiber/v2"
	"log"
)

func main() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		html := `
<!DOCTYPE html>
<html>
<head>
    <title>My Go Website</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        nav { margin-bottom: 20px; }
        nav a { margin-right: 20px; text-decoration: none; color: #007bff; }
        .hero { background: #f8f9fa; padding: 40px; border-radius: 8px; text-align: center; }
        .features { margin: 20px 0; }
        .features ul { display: flex; gap: 20px; justify-content: center; list-style: none; padding: 0; }
        .features li { background: #007bff; color: white; padding: 10px 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <nav>
            <a href="/">Home</a>
            <a href="/about">About</a>
        </nav>
        
        <div class="hero">
            <h1>Welcome to My Go Website</h1>
            <p>Built with Go Fiber - Fast, Simple, and Embedded!</p>
        </div>
        
        <div class="features">
            <h2>Features</h2>
            <ul>
                <li>Lightning Fast</li>
                <li>Single Binary</li>
                <li>No External Files</li>
            </ul>
        </div>
    </div>
</body>
</html>`

		c.Type("html")
		return c.SendString(html)
	})

	app.Get("/about", func(c *fiber.Ctx) error {
		html := `
<!DOCTYPE html>
<html>
<head>
    <title>About - My Go Website</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        nav { margin-bottom: 20px; }
        nav a { margin-right: 20px; text-decoration: none; color: #007bff; }
        .content { background: #f8f9fa; padding: 30px; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <nav>
            <a href="/">Home</a>
            <a href="/about">About</a>
        </nav>
        
        <div class="content">
            <h1>About This Website</h1>
            <p>This is a simple website built with Go Fiber framework.</p>
            <p>Everything is embedded in a single Go binary - no external template or static files needed!</p>
            
            <h2>Tech Stack</h2>
            <ul>
                <li>Go (Golang)</li>
                <li>Fiber Web Framework</li>
                <li>Embedded HTML & CSS</li>
            </ul>
        </div>
    </div>
</body>
</html>`

		c.Type("html")
		return c.SendString(html)
	})

	log.Println("Server starting on http://localhost:3000")
	log.Fatal(app.Listen(":3000"))
}
