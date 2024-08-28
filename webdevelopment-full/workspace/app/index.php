<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        p {
            color: #666;
            text-align: center;
        }
        #phpinfo {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello World</h1>
        <p>This is a test PHP file.</p>
        <button onclick="togglePhpInfo()">Toggle PHP Info</button>
        <div id="phpinfo">
            <?php
            // Display PHP information
            phpinfo();
            ?>
        </div>
    </div>
    <script>
        function togglePhpInfo() {
            var phpInfoDiv = document.getElementById("phpinfo");
            if (phpInfoDiv.style.display === "none") {
                phpInfoDiv.style.display = "block";
            } else {
                phpInfoDiv.style.display = "none";
            }
        }
    </script>
</body>
</html>
