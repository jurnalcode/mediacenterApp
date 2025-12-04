<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$response = [
    'success' => true,
    'message' => 'Mazadie News API v1.0',
    'endpoints' => [
        'posts' => [
            'url' => 'posts.php',
            'methods' => ['GET'],
            'description' => 'Get all posts or single post',
            'parameters' => [
                'id' => 'Post ID (optional)',
                'page' => 'Page number for pagination (default: 1)',
                'limit' => 'Items per page (default: 10)',
                'category' => 'Filter by category ID (optional)',
                'search' => 'Search in post titles (optional)'
            ],
            'examples' => [
                'Get all posts' => 'posts.php',
                'Get posts with pagination' => 'posts.php?page=1&limit=5',
                'Get single post' => 'posts.php?id=1',
                'Get posts by category' => 'posts.php?category=1',
                'Search posts' => 'posts.php?search=indonesia'
            ]
        ],
        'categories' => [
            'url' => 'categories.php',
            'methods' => ['GET'],
            'description' => 'Get all categories or single category',
            'parameters' => [
                'id' => 'Category ID (optional)'
            ],
            'examples' => [
                'Get all categories' => 'categories.php',
                'Get single category' => 'categories.php?id=1'
            ]
        ],
        'pages' => [
            'url' => 'pages.php',
            'methods' => ['GET'],
            'description' => 'Get all pages or single page',
            'parameters' => [
                'id' => 'Page ID (optional)'
            ],
            'examples' => [
                'Get all pages' => 'pages.php',
                'Get single page' => 'pages.php?id=1'
            ]
        ],
        'contact' => [
            'url' => 'contact.php',
            'methods' => ['GET', 'POST'],
            'description' => 'Submit contact form',
            'parameters' => [
                'name' => 'Contact name (required for POST)',
                'email' => 'Contact email (required for POST)',
                'subject' => 'Message subject (required for POST)',
                'message' => 'Message content (required for POST)'
            ],
            'examples' => [
                'Submit contact form' => 'POST contact.php with JSON body'
            ]
        ]
    ],
    'base_url' => 'https://sontiank.com/po-includes/api/',
    'image_base_url' => 'https://sontiank.com/po-content/uploads/',
    'thumb_base_url' => 'https://sontiank.com/po-content/thumbs/'
];

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>