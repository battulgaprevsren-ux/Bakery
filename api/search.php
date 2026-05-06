<?php
// search_products.php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "bakery_db";

// Холболт үүсгэх
$conn = new mysqli($servername, $username, $password, $dbname);

// Холболт шалгах
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Хэрэглэгчийн input-г авах
$search = isset($_GET['q']) ? $_GET['q'] : '';
$filter = isset($_GET['cat']) ? $_GET['cat'] : 'all';

// 🚨 VULNERABLE SQL QUERY (SQL INJECTION ЖИШЭЭ)
// Энэ нь суралцах зорилгоор ХАМГААЛАЛТГҮЙ хийгдсэн

$sql = "SELECT * FROM products WHERE 1=1";

// Хайлтын нөхцөл - ЭМЗЭЛТТЭЙ (vulnerable)
if (!empty($search)) {
    $sql .= " AND name LIKE '%$search%'";
}

// Фильтрийн нөхцөл
if ($filter != 'all') {
    $sql .= " AND category = '$filter'";
}

$result = $conn->query($sql);

$products = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $products[] = $row;
    }
}

// JSON хэлбэрээр буцаах
header('Content-Type: application/json');
echo json_encode($products);

$conn->close();
?>