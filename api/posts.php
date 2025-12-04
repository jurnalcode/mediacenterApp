<?php
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
                // Get single post
                $post_id = (int)$_GET['id'];
                $post = $core->podb->from('post p')
                    ->leftJoin('post_description pd ON p.id_post = pd.id_post')
                    ->leftJoin('post_category pc ON p.id_post = pc.id_post')
                    ->leftJoin('category_description cd ON pc.id_category = cd.id_category')
                    ->select('p.*, pd.title, pd.content, cd.title as category_name')
                    ->where('p.id_post', $post_id)
                    ->where('p.active', 'Y')
                    ->where('pd.id_language', 1)
                    ->where('cd.id_language', 1)
                    ->fetch();
                
                if ($post) {
                    // Update hits
                    $core->podb->update('post')
                        ->set(['hits' => $post['hits'] + 1])
                        ->where('id_post', $post_id)
                        ->execute();
                    
                    $response = [
                        'success' => true,
                        'data' => [
                            'id' => (int)$post['id_post'],
                            'title' => html_entity_decode($post['title']),
                            'content' => html_entity_decode($post['content']),
                            'seotitle' => $post['seotitle'],
                            'picture' => $post['picture'],
                            'picture_description' => $post['picture_description'],
                            'date' => $post['date'],
                            'time' => $post['time'],
                            'hits' => (int)$post['hits'] + 1,
                            'category' => $post['category_name'],
                            'tag' => $post['tag']
                        ]
                    ];
                } else {
                    $response = [
                        'success' => false,
                        'message' => 'Post not found'
                    ];
                }
            } else {
                // Get all posts with pagination
                $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
                $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
                $category_id = isset($_GET['category']) ? (int)$_GET['category'] : null;
                $search = isset($_GET['search']) ? $_GET['search'] : null;
                
                $offset = ($page - 1) * $limit;
                
                $query = $core->podb->from('post p')
                    ->leftJoin('post_description pd ON p.id_post = pd.id_post AND pd.id_language = 1')
                    ->leftJoin('post_category pc ON p.id_post = pc.id_post')
                    ->leftJoin('category_description cd ON pc.id_category = cd.id_category AND cd.id_language = 1')
                    ->select('p.id_post, p.seotitle, p.picture, p.picture_description, p.date, p.time, p.hits, p.headline, pd.title, pd.content, cd.title as category_name')
                    ->where('p.active', 'Y')
                    ->orderBy('p.publishdate DESC');
                
                if ($category_id) {
                    $query = $query->where('pc.id_category', $category_id);
                }
                
                if ($search) {
                    $query = $query->where('pd.title LIKE ?', '%' . $search . '%');
                }
                
                // Get total count
                $total_query = $core->podb->from('post p')
                    ->leftJoin('post_description pd ON p.id_post = pd.id_post AND pd.id_language = 1')
                    ->leftJoin('post_category pc ON p.id_post = pc.id_post')
                    ->select('COUNT(DISTINCT p.id_post) as total')
                    ->where('p.active', 'Y');
                
                if ($category_id) {
                    $total_query = $total_query->where('pc.id_category', $category_id);
                }
                
                if ($search) {
                    $total_query = $total_query->where('pd.title LIKE ?', '%' . $search . '%');
                }
                
                $total_result = $total_query->fetch();
                $total = $total_result['total'];
                
                $posts = $query->limit($limit)->offset($offset)->fetchAll();
                
                $data = [];
                foreach ($posts as $post) {
                    $content_preview = strip_tags(html_entity_decode($post['content']));
                    $content_preview = substr($content_preview, 0, 999999) . '...';
                    
                    $data[] = [
                        'id' => (int)$post['id_post'],
                        'title' => html_entity_decode($post['title']),
                        'content_preview' => $content_preview,
                        'seotitle' => $post['seotitle'],
                        'picture' => $post['picture'],
                        'picture_description' => $post['picture_description'],
                        'date' => $post['date'],
                        'time' => $post['time'],
                        'hits' => (int)$post['hits'],
                        'headline' => $post['headline'],
                        'category' => $post['category_name']
                    ];
                }
                
                $response = [
                    'success' => true,
                    'data' => $data,
                    'pagination' => [
                        'current_page' => $page,
                        'total_pages' => ceil($total / $limit),
                        'total_items' => $total,
                        'items_per_page' => $limit
                    ]
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

echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>