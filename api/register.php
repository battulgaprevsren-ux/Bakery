<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';

$data = json_decode(file_get_contents('php://input'), true);
$name = trim($data['full_name'] ?? '');
$email = trim($data['email'] ?? '');
$phone = trim($data['phone'] ?? '');
$pass = $data['password'] ?? '';

if (!$name || !$email || !$pass) {
    echo json_encode(['success' => false, 'message' => 'Мэдээлэл дутуу байна']);
    exit;
}

$db = getDB();
$hash = password_hash($pass, PASSWORD_DEFAULT);

$stmt = $db->prepare("INSERT INTO customers (full_name, email, phone, password_hash) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $name, $email, $phone, $hash);

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Бүртгэлтэй имэйл байна']);
}
$stmt->close();
$db->close();
?>
