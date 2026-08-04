<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your OTP Code</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            background-color: #f4f7fa;
            margin: 0;
            padding: 0;
            color: #333333;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        .header {
            background-color: #0d6efd;
            padding: 30px 20px;
            text-align: center;
        }
        .header img {
            max-height: 50px;
            margin-bottom: 15px;
        }
        .header h1 {
            color: #ffffff;
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }
        .content {
            padding: 40px 30px;
            text-align: center;
        }
        .content p {
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 25px;
        }
        .otp-code {
            font-size: 110px;
            font-weight: bold;
            color: #0d6efd;
            letter-spacing: 16px;
            margin: 50px 0;
            display: block;
            text-align: center;
        }
        .warning {
            font-size: 14px;
            color: #6c757d;
            margin-top: 30px;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 20px;
            text-align: center;
            border-top: 1px solid #e9ecef;
        }
        .footer p {
            margin: 0;
            font-size: 13px;
            color: #adb5bd;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <!-- Embed image with CID -->
            <img src="{{ $message->embed(public_path('images/logo-nirpay.png')) }}" alt="Nirpay Logo">
            <h1>Verification Code</h1>
        </div>
        
        <div class="content">
            <p>Hi there,</p>
            <p>You recently requested to <strong>{{ $purpose }}</strong> your account. Please use the following One-Time Password (OTP) to complete the process:</p>
            
            <p class="otp-code" style="font-size: 40px; font-weight: bold; color: #0d6efd; letter-spacing: 12px; margin: 30px 0; display: block; text-align: center; white-space: nowrap;">
                {{ $otpCode }}
            </p>
            
            <p class="warning">
                This code is valid for <strong>5 minutes</strong>.<br>
                Please do not share this code with anyone. If you didn't request this, you can safely ignore this email.
            </p>
        </div>
        
        <div class="footer">
            <p>&copy; {{ date('Y') }} Nirpay. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
