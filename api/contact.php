<?php
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
        case 'POST':
            // Submit contact form
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input) {
                $input = $_POST;
            }
            
            $name = isset($input['name']) ? trim($input['name']) : '';
            $email = isset($input['email']) ? trim($input['email']) : '';
            $subject = isset($input['subject']) ? trim($input['subject']) : '';
            $message = isset($input['message']) ? trim($input['message']) : '';
            
            // Validation
            $errors = [];
            
            if (empty($name)) {
                $errors[] = 'Name is required';
            }
            
            if (empty($email)) {
                $errors[] = 'Email is required';
            } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $errors[] = 'Invalid email format';
            }
            
            if (empty($subject)) {
                $errors[] = 'Subject is required';
            }
            
            if (empty($message)) {
                $errors[] = 'Message is required';
            }
            
            if (!empty($errors)) {
                $response = [
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $errors
                ];
            } else {
                // Insert contact message
                $insert_result = $core->podb->insertInto('contact')
                    ->values([
                        'name' => $name,
                        'email' => $email,
                        'subject' => $subject,
                        'message' => $message,
                        'status' => 'N'
                    ])
                    ->execute();
                
                if ($insert_result) {
                    $response = [
                        'success' => true,
                        'message' => 'Contact message sent successfully'
                    ];
                } else {
                    $response = [
                        'success' => false,
                        'message' => 'Failed to send contact message'
                    ];
                }
            }
            break;
            
        case 'GET':
            // Get contact information (if needed)
            $response = [
                'success' => true,
                'data' => [
                    'message' => 'Contact API is working. Use POST method to submit contact form.'
                ]
            ];
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