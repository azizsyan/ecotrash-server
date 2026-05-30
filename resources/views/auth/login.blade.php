<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>
        Login - EcoTrash
    </title>

    <link
        href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"
        rel="stylesheet"
    >

    @vite([
        'resources/css/app.css',
        'resources/js/app.js'
    ])
</head>

<body>

    <div
        style="
            min-height:100vh;
            display:flex;
        "
    >

        {{-- LEFT PANEL --}}
        <div
            style="
                flex:1;
                background:#1f8f55;
                display:flex;
                align-items:center;
                justify-content:center;
                color:white;
                padding:40px;
            "
        >

            <div
                style="
                    text-align:center;
                    max-width:500px;
                "
            >

                <h1
                    style="
                        font-size:72px;
                        margin:0;
                        font-weight:700;
                    "
                >
                    EcoTrash
                </h1>

                <p
                    style="
                        margin-top:12px;
                        font-size:20px;
                        opacity:.9;
                    "
                >
                    EcoTrash Administration Panel
                </p>

            </div>

        </div>

        {{-- RIGHT PANEL --}}
        <div
            style="
                width:500px;
                background:white;
                display:flex;
                align-items:center;
                justify-content:center;
                padding:40px;
            "
        >

            <div
                style="
                    width:100%;
                "
            >

                <h2
                    style="
                        font-size:44px;
                        margin-bottom:10px;
                        font-weight:700;
                    "
                >
                    Login
                </h2>

                <p
                    style="
                        color:#6b7280;
                        margin-bottom:40px;
                    "
                >
                    Masuk ke Dashboard EcoTrash
                </p>

                <form
                    action="/login"
                    method="POST"
                >

                    @csrf

                    {{-- Email --}}
                    <div
                        style="
                            margin-bottom:20px;
                        "
                    >

                        <label
                            style="
                                display:block;
                                margin-bottom:8px;
                                font-weight:500;
                            "
                        >
                            Email
                        </label>

                        <input
                            type="email"
                            name="email"
                            required
                            style="
                                width:100%;
                                padding:16px;
                                border:1px solid #d1d5db;
                                border-radius:14px;
                                font-size:16px;
                            "
                        >

                    </div>

                    {{-- Password --}}
                    <div
                        style="
                            margin-bottom:20px;
                        "
                    >

                        <label
                            style="
                                display:block;
                                margin-bottom:8px;
                                font-weight:500;
                            "
                        >
                            Password
                        </label>

                        <input
                            type="password"
                            name="password"
                            required
                            style="
                                width:100%;
                                padding:16px;
                                border:1px solid #d1d5db;
                                border-radius:14px;
                                font-size:16px;
                            "
                        >

                    </div>

                    @error('email')

                        <div
                            style="
                                background:#fde8e8;
                                color:#dc2626;
                                padding:14px;
                                border-radius:12px;
                                margin-bottom:20px;
                            "
                        >
                            {{ $message }}
                        </div>

                    @enderror

                    <button
                        type="submit"
                        style="
                            width:100%;
                            border:none;
                            border-radius:16px;
                            background:#1f8f55;
                            color:white;
                            padding:18px;
                            font-size:18px;
                            font-weight:600;
                            cursor:pointer;
                        "
                    >
                        Login
                    </button>

                </form>

            </div>

        </div>

    </div>

</body>

</html>