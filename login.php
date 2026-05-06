<?php
session_start();
// If already logged in, redirect to main page
if (isset($_SESSION['user_id'])) {
    header('Location: main.php');
    exit();
}
?>
<!DOCTYPE html>
<html lang="mn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Нэвтрэх - Bakery</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: linear-gradient(135deg, #faf7f4 0%, #f0e8e0 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .auth-container {
            max-width: 450px;
            width: 100%;
        }

        .auth-card {
            background: white;
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            overflow: hidden;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .auth-header {
            background: linear-gradient(135deg, #3d1f0a 0%, #6b3a1f 100%);
            padding: 40px 30px;
            text-align: center;
        }

        .auth-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 42px;
            color: #ffd580;
            margin-bottom: 8px;
        }

        .auth-header p {
            color: rgba(255,240,200,0.7);
            font-size: 14px;
        }

        .auth-body {
            padding: 32px;
        }

        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 28px;
            border-bottom: 2px solid #f0f0f0;
        }

        .tab {
            flex: 1;
            text-align: center;
            padding: 12px;
            font-size: 16px;
            font-weight: 500;
            color: #888;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            transition: all 0.2s;
        }

        .tab.active {
            color: #8b4513;
            border-bottom-color: #8b4513;
        }

        .form {
            display: none;
        }

        .form.active {
            display: block;
            animation: fadeIn 0.3s ease;
        }

        .field {
            margin-bottom: 20px;
        }

        .field label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #555;
            margin-bottom: 6px;
        }

        .field input {
            width: 100%;
            padding: 12px 14px;
            border: 1.5px solid #e0e0e0;
            border-radius: 12px;
            font-size: 14px;
            font-family: 'DM Sans', sans-serif;
            transition: all 0.2s;
        }

        .field input:focus {
            outline: none;
            border-color: #8b4513;
            box-shadow: 0 0 0 3px rgba(139,69,19,0.1);
        }

        .password-wrapper {
            position: relative;
        }

        .password-wrapper input {
            padding-right: 45px;
        }

        .toggle-btn {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            font-size: 18px;
            color: #999;
            padding: 5px;
        }

        .btn-submit {
            width: 100%;
            padding: 14px;
            background: #8b4513;
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 10px;
        }

        .btn-submit:hover {
            background: #6b3310;
        }

        .message {
            margin-top: 16px;
            padding: 10px;
            border-radius: 8px;
            font-size: 13px;
            text-align: center;
            display: none;
        }

        .message.error {
            background: #fee;
            color: #c33;
            display: block;
        }

        .message.success {
            background: #efe;
            color: #3a7;
            display: block;
        }

        .password-hint {
            font-size: 11px;
            color: #999;
            margin-top: 5px;
        }

        .bakery-icon {
            font-size: 48px;
            text-align: center;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <div class="bakery-icon">🥐</div>
            <h1>Bakery</h1>
            <p>Амттай нарийн боовны ертөнцөд тавтай морил</p>
        </div>

        <div class="auth-body">
            <div class="tabs">
                <div class="tab active" onclick="switchTab('login')">Нэвтрэх</div>
                <div class="tab" onclick="switchTab('register')">Бүртгүүлэх</div>
            </div>

            <!-- Login Form -->
            <div class="form active" id="loginForm">
                <div class="field">
                    <label>Имэйл</label>
                    <input type="email" id="loginEmail" placeholder="name@example.mn">
                </div>
                <div class="field">
                    <label>Нууц үг</label>
                    <div class="password-wrapper">
                        <input type="password" id="loginPass" placeholder="••••••••">
                        <button type="button" class="toggle-btn" onclick="togglePassword('loginPass', this)">👁️</button>
                    </div>
                </div>
                <button class="btn-submit" onclick="doLogin()">Нэвтрэх</button>
                <div class="message" id="loginMessage"></div>
            </div>

            <!-- Register Form -->
            <div class="form" id="registerForm">
                <div class="field">
                    <label>Овог нэр</label>
                    <input type="text" id="regName" placeholder="Болд Батбаяр">
                </div>
                <div class="field">
                    <label>Имэйл</label>
                    <input type="email" id="regEmail" placeholder="name@example.mn">
                </div>
                <div class="field">
                    <label>Утасны дугаар</label>
                    <input type="tel" id="regPhone" placeholder="+976 9900-0000">
                </div>
                <div class="field">
                    <label>Нууц үг</label>
                    <div class="password-wrapper">
                        <input type="password" id="regPass" placeholder="••••••••">
                        <button type="button" class="toggle-btn" onclick="togglePassword('regPass', this)">👁️</button>
                    </div>
                    <div class="password-hint">✓ Хамгийн багадаа 8 тэмдэгт<br>✓ 1 том үсэг (A-Z)<br>✓ 1 тэмдэгт (!@#$%^&*)</div>
                </div>
                <div class="field">
                    <label>Нууц үг баталгаажуулах</label>
                    <div class="password-wrapper">
                        <input type="password" id="regConfirmPass" placeholder="••••••••">
                        <button type="button" class="toggle-btn" onclick="togglePassword('regConfirmPass', this)">👁️</button>
                    </div>
                </div>
                <button class="btn-submit" onclick="doRegister()">Бүртгүүлэх</button>
                <div class="message" id="registerMessage"></div>
            </div>
        </div>
    </div>
</div>

<script>
    function switchTab(tab) {
        const tabs = document.querySelectorAll('.tab');
        const forms = document.querySelectorAll('.form');
        
        tabs.forEach(t => t.classList.remove('active'));
        forms.forEach(f => f.classList.remove('active'));
        
        if (tab === 'login') {
            tabs[0].classList.add('active');
            document.getElementById('loginForm').classList.add('active');
        } else {
            tabs[1].classList.add('active');
            document.getElementById('registerForm').classList.add('active');
        }
        
        // Clear messages
        document.getElementById('loginMessage').className = 'message';
        document.getElementById('registerMessage').className = 'message';
    }
    
    function togglePassword(inputId, btn) {
        const input = document.getElementById(inputId);
        const type = input.type === 'password' ? 'text' : 'password';
        input.type = type;
        btn.textContent = type === 'text' ? '🙈' : '👁️';
    }
    
    async function doLogin() {
        const email = document.getElementById('loginEmail').value.trim();
        const password = document.getElementById('loginPass').value;
        const msgDiv = document.getElementById('loginMessage');
        
        if (!email || !password) {
            msgDiv.textContent = 'Бүх талбарыг бөглөнө үү';
            msgDiv.className = 'message error';
            return;
        }
        
        msgDiv.textContent = 'Уншиж байна...';
        msgDiv.className = 'message';
        
        try {
            const response = await fetch('api/login.php', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({email: email, password: password})
            });
            const data = await response.json();
            
            if (data.success) {
                msgDiv.textContent = 'Амжилттай нэвтэрлээ! Хүлээнэ үү...';
                msgDiv.className = 'message success';
                setTimeout(() => {
                    window.location.href = 'main.php';
                }, 800);
            } else {
                msgDiv.textContent = data.message || 'Нэвтрэхэд алдаа гарлаа';
                msgDiv.className = 'message error';
            }
        } catch (error) {
            msgDiv.textContent = 'Сервертэй холбогдсонгүй';
            msgDiv.className = 'message error';
        }
    }
    
    async function doRegister() {
        const name = document.getElementById('regName').value.trim();
        const email = document.getElementById('regEmail').value.trim();
        const phone = document.getElementById('regPhone').value.trim();
        const pass = document.getElementById('regPass').value;
        const confirmPass = document.getElementById('regConfirmPass').value;
        const msgDiv = document.getElementById('registerMessage');
        
        if (!name || !email || !phone || !pass || !confirmPass) {
            msgDiv.textContent = 'Бүх талбарыг бөглөнө үү';
            msgDiv.className = 'message error';
            return;
        }
        
        if (pass !== confirmPass) {
            msgDiv.textContent = 'Нууц үгүүд хоорондоо тохирохгүй байна';
            msgDiv.className = 'message error';
            return;
        }
        
        // Password validation
        if (pass.length < 8) {
            msgDiv.textContent = 'Нууц үг 8 ба түүнээс дээш тэмдэгттэй байх ёстой';
            msgDiv.className = 'message error';
            return;
        }
        
        if (!/[A-Z]/.test(pass)) {
            msgDiv.textContent = 'Нууц үг 1 том үсэг агуулсан байх ёстой';
            msgDiv.className = 'message error';
            return;
        }
        
        if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pass)) {
            msgDiv.textContent = 'Нууц үг 1 тэмдэгт (!@#$%^&*) агуулсан байх ёстой';
            msgDiv.className = 'message error';
            return;
        }
        
        msgDiv.textContent = 'Бүртгэж байна...';
        msgDiv.className = 'message';
        
        try {
            const response = await fetch('api/register.php', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    full_name: name,
                    email: email,
                    phone: phone,
                    password: pass
                })
            });
            const data = await response.json();
            
            if (data.success) {
                msgDiv.textContent = 'Бүртгэл амжилттай! Та нэвтэрч болно';
                msgDiv.className = 'message success';
                setTimeout(() => switchTab('login'), 1500);
            } else {
                msgDiv.textContent = data.message || 'Бүртгэл амжилтгүй';
                msgDiv.className = 'message error';
            }
        } catch (error) {
            msgDiv.textContent = 'Сервертэй холбогдсонгүй';
            msgDiv.className = 'message error';
        }
    }
</script>
</body>
</html>