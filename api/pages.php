<?php
session_start();
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
                // Get single page
                $page_id = (int)$_GET['id'];
                $page = $core->podb->from('pages p')
                    ->leftJoin('pages_description pd ON p.id_pages = pd.id_pages')
                    ->select('p.*, pd.title, pd.content')
                    ->where('p.id_pages', $page_id)
                    ->where('p.active', 'Y')
                    ->where('pd.id_language', 1)
                    ->fetch();
                
                if ($page) {
                    $response = [
                        'success' => true,
                        'data' => [
                            'id' => $page['id_pages'],
                            'title' => html_entity_decode($page['title']),
                            'content' => html_entity_decode($page['content']),
                            'seotitle' => $page['seotitle'],
                            'picture' => $page['picture'],
                            'date' => $page['date'],
                            'time' => $page['time']
                        ]
                    ];
                } else {
                    $response = [
                        'success' => false,
                        'message' => 'Page not found'
                    ];
                }
            } else {
                // Get all pages
                $pages = $core->podb->from('pages p')
                    ->leftJoin('pages_description pd ON p.id_pages = pd.id_pages')
                    ->select('p.id_pages, p.seotitle, p.picture, pd.title, pd.content')
                    ->where('p.active', 'Y')
                    ->where('pd.id_language', 1)
                    ->orderBy('pd.title ASC')
                    ->fetchAll();
                
                $data = [];
                if ($pages && is_array($pages)) {
                    foreach ($pages as $page) {
                        $content_preview = strip_tags(html_entity_decode($page['content']));
                        $content_preview = substr($content_preview, 0, 150) . '...';
                        
                        $data[] = [
                            'id' => $page['id_pages'],
                            'title' => html_entity_decode($page['title']),
                            'content_preview' => $content_preview,
                            'seotitle' => $page['seotitle'],
                            'picture' => $page['picture']
                        ];
                    }
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

echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>