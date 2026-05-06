<?php
session_start();
header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "bakery_db");

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed"]));
}

$data = json_decode(file_get_contents('php://input'), true);
$email = $data['email'] ?? '';
$plain_password = $data['password'] ?? '';

// 🚨 VULNERABLE to SQL injection (for learning)
$sql = "SELECT id, full_name, password FROM users WHERE email = '$email'";
$result = $conn->query($sql);

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();
    
    if (password_verify($plain_password, $user['password'])) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_name'] = $user['full_name'];
        
        echo json_encode([
            "success" => true, 
            "full_name" => $user['full_name']
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Нууц үг буруу"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Имэйл бүртгэлгүй байна"]);
}

$conn->close();
?>