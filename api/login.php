<?php
header('Content-Type: application/json'); // Хариултыг JSON форматаар илгээнэ
session_start();

// config.php файл байгаа эсэхийг шалгах
if (!file_exists(__DIR__ . '/config.php')) {
    echo json_encode(['success' => false, 'message' => 'Тохиргооны файл (config.php) олдсонгүй']);
    exit;
}

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'POST method шаардлагатай']);
    exit;
}

// Frontend-ээс ирж буй өгөгдлийг унших
$data     = json_decode(file_get_contents('php://input'), true);
$email    = trim($data['email']    ?? '');
$password = $data['password']      ?? '';

if (!$email || !$password) {
    echo json_encode(['success' => false, 'message' => 'Имэйл болон нууц үг оруулна уу']);
    exit;
}

try {
    $db = getDB();

    // Хэрэглэгч хайх
    $stmt = $db->prepare('SELECT customer_id, full_name, password_hash, is_active FROM customers WHERE email = ? LIMIT 1');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $result = $stmt->get_result()->fetch_assoc();
    $stmt->close();

    if (!$result) {
        echo json_encode(['success' => false, 'message' => 'Бүртгэлгүй хэрэглэгч байна']);
        $db->close();
        exit;
    }

    if (!$result['is_active']) {
        echo json_encode(['success' => false, 'message' => 'Таны бүртгэл идэвхгүй байна']);
        $db->close();
        exit;
    }

    // Нууц үг шалгах
    if (!password_verify($password, $result['password_hash'])) {
        echo json_encode(['success' => false, 'message' => 'Нууц үг буруу байна']);
        $db->close();
        exit;
    }

    // Session үүсгэх
    $_SESSION['customer_id'] = $result['customer_id'];
    $_SESSION['full_name']   = $result['full_name'];
    $_SESSION['email']       = $email;

    echo json_encode([
        'success'   => true,
        'message'   => 'Амжилттай нэвтэрлээ!',
        'full_name' => $result['full_name']
    ]);

    $db->close();

} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Системийн алдаа: ' . $e->getMessage()]);
}
?>