<?php
header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "bakery_db");

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

$data = json_decode(file_get_contents('php://input'), true);

$full_name = $data['full_name'] ?? '';
$email = $data['email'] ?? '';
$phone = $data['phone'] ?? '';
$plain_password = $data['password'] ?? '';

// Server-side password validation
$hasMinLength = strlen($plain_password) >= 8;
$hasCapital = preg_match('/[A-Z]/', $plain_password);
$hasSymbol = preg_match('/[!@#$%^&*()_+\-=\[\]{};\':"\\|,.<>\/?]/', $plain_password);

if (!$hasMinLength || !$hasCapital || !$hasSymbol) {
    echo json_encode([
        "success" => false, 
        "message" => "Нууц үг 8+ тэмдэгт, 1 том үсэг, 1 тэмдэгт агуулсан байх ёстой"
    ]);
    exit;
}

$hashed_password = password_hash($plain_password, PASSWORD_DEFAULT);

// 🚨 VULNERABLE to SQL injection (for learning)
$check_sql = "SELECT id FROM users WHERE email = '$email'";
$check_result = $conn->query($check_sql);

if ($check_result->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Имэйл бүртгэлтэй байна"]);
    exit;
}

$insert_sql = "INSERT INTO users (full_name, email, phone, password) 
               VALUES ('$full_name', '$email', '$phone', '$hashed_password')";

if ($conn->query($insert_sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Бүртгэл амжилттай"]);
} else {
    echo json_encode(["success" => false, "message" => "Алдаа: " . $conn->error]);
}

$conn->close();
?>