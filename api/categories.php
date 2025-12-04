<?php
// Suppress PHP errors and warnings to prevent JSON corruption
error_reporting(0);
ob_start();

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once '../core/core.php';

$core = new PoCore();

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Get single category
                $category_id = (int)$_GET['id'];
                $category = $core->podb->from('category c')
                    ->leftJoin('category_description cd ON c.id_category = cd.id_category')
                    ->select('c.*, cd.title')
                    ->where('c.id_category', $category_id)
                    ->where('c.active', 'Y')
                    ->where('cd.id_language', 1)
                    ->fetch();
                
                if ($category) {
                    // Get posts count in this category
                    $posts_count = $core->podb->from('post_category pc')
                        ->leftJoin('post p ON pc.id_post = p.id_post')
                        ->select('COUNT(*) as total')
                        ->where('pc.id_category', $category_id)
                        ->where('p.active', 'Y')
                        ->fetch();
                    
                    $response = [
                        'success' => true,
                        'data' => [
                            'id' => (int)$category['id_category'],
                            'title' => html_entity_decode($category['title']),
                            'seotitle' => $category['seotitle'],
                            'picture' => $category['picture'],
                            'posts_count' => (int)$posts_count['total']
                        ]
                    ];
                } else {
                    $response = [
                        'success' => false,
                        'message' => 'Category not found'
                    ];
                }
            } else {
                // Get all categories
                $categories = $core->podb->from('category c')
                    ->leftJoin('category_description cd ON c.id_category = cd.id_category')
                    ->select('c.id_category, c.seotitle, c.picture, cd.title')
                    ->where('c.active', 'Y')
                    ->where('cd.id_language', 1)
                    ->orderBy('cd.title ASC')
                    ->fetchAll();
                
                $data = [];
                foreach ($categories as $category) {
                    // Get posts count for each category
                    $posts_count = $core->podb->from('post_category pc')
                        ->leftJoin('post p ON pc.id_post = p.id_post')
                        ->select('COUNT(*) as total')
                        ->where('pc.id_category', $category['id_category'])
                        ->where('p.active', 'Y')
                        ->fetch();
                    
                    $data[] = [
                        'id' => (int)$category['id_category'],
                        'title' => html_entity_decode($category['title']),
                        'seotitle' => $category['seotitle'],
                        'picture' => $category['picture'],
                        'posts_count' => (int)$posts_count['total']
                    ];
                }
                
                $response = [
                    'success' => true,
                    'data' => $data
                ];
            }
            break;
            
        default:
            $response = [
                'success' => false,
                'message' => 'Method not allowed'
            ];
            break;
    }
    
} catch (Exception $e) {
    $response = [
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ];
}

// Clean output buffer and send only JSON
ob_end_clean();
echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>